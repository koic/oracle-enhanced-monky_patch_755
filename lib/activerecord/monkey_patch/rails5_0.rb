module ActiveRecord
  module MonkeyPatch
    SUPPORTED_MAJOR_VERSION = 5
    MINIMUM_SUPPORTED_VERSION = '5.0.0'.freeze
  end

  #
  # Original code is the following URL.
  #
  # https://github.com/rails/rails/blob/v5.0.0.1/activerecord/lib/active_record/internal_metadata.rb#L18
  #
  class InternalMetadata < ActiveRecord::Base
     class << self
       def []=(key, value)
         find_or_initialize_by(key: key).update_attributes!(value: value.to_s)
       end
     end
  end

  module ConnectionAdapters
    #
    # Original code is the following URL.
    #
    #   https://github.com/rsim/oracle-enhanced/blob/rails5/lib/active_record/connection_adapters/oracle_enhanced_adapter.rb#L938
    #
    class OracleEnhancedAdapter
      def columns_without_cache(table_name, name = nil) #:nodoc:
        table_name = table_name.to_s
        # get ignored_columns by original table name
        ignored_columns = ignored_table_columns(table_name)

        (owner, desc_table_name, db_link) = @connection.describe(table_name)

        # reset do_not_prefetch_primary_key cache for this table
        @@do_not_prefetch_primary_key[table_name] = nil

        table_cols = <<-SQL.strip.gsub(/\s+/, ' ')
          SELECT cols.column_name AS name, cols.data_type AS sql_type,
                 cols.data_default, cols.nullable, cols.virtual_column, cols.hidden_column,
                 cols.data_type_owner AS sql_type_owner,
                 DECODE(cols.data_type, 'NUMBER', data_precision,
                                   'FLOAT', data_precision,
                                   'VARCHAR2', DECODE(char_used, 'C', char_length, data_length),
                                   'RAW', DECODE(char_used, 'C', char_length, data_length),
                                   'CHAR', DECODE(char_used, 'C', char_length, data_length),
                                    NULL) AS limit,
                 DECODE(data_type, 'NUMBER', data_scale, NULL) AS scale,
                 comments.comments as column_comment
            FROM all_tab_cols#{db_link} cols, all_col_comments#{db_link} comments
           WHERE cols.owner      = '#{owner}'
             AND cols.table_name = '#{desc_table_name}'
             AND cols.hidden_column = 'NO'
             AND cols.owner = comments.owner
             AND cols.table_name = comments.table_name
             AND cols.column_name = comments.column_name
           ORDER BY cols.column_id
        SQL

        # added deletion of ignored columns
        select_all(table_cols, name).to_a.delete_if do |row|
          ignored_columns && ignored_columns.include?(row['name'].downcase)
        end.map do |row|
          limit, scale = row['limit'], row['scale']
          if limit || scale
            row['sql_type'] += "(#{(limit || 38).to_i}" + ((scale = scale.to_i) > 0 ? ",#{scale})" : ")")
          end

          if row['sql_type_owner']
            row['sql_type'] = row['sql_type_owner'] + '.' + row['sql_type']
          end

          is_virtual = row['virtual_column']=='YES'

          # clean up odd default spacing from Oracle
          if row['data_default'] && !is_virtual
            row['data_default'].sub!(/^(.*?)\s*$/, '\1')

            # If a default contains a newline these cleanup regexes need to
            # match newlines.
            row['data_default'].sub!(/^'(.*)'$/m, '\1')
            row['data_default'] = nil if row['data_default'] =~ /^(null|empty_[bc]lob\(\))$/i
            # TODO: Needs better fix to fallback "N" to false
            row['data_default'] = false if (row['data_default'] == "N" && OracleEnhancedAdapter.emulate_booleans_from_strings)
          end

          type_metadata = fetch_type_metadata(row['sql_type'])

          # *** Its a monkey patch paragraph. ***
          if /date/i === type_metadata.sql_type
            if type_metadata.type == :date
              type_metadata.instance_eval('@sql_type = "DATETIME"')
            end
          end

          new_column(oracle_downcase(row['name']),
                           row['data_default'],
                           type_metadata,
                           row['nullable'] == 'Y',
                           table_name,
                           is_virtual,
                           false,
                           row['column_comment']
                    )
        end
      end
    end

    module OracleEnhanced
      #
      # Original code is the following URL.
      #
      # https://github.com/rsim/oracle-enhanced/blob/rails5/lib/active_record/connection_adapters/oracle_enhanced/quoting.rb#L87
      #
      module Quoting
        def quote(value, column = nil) #:nodoc:
          case value
          when ::Date, ::Time, ::DateTime # *** Its a monky patch condition. ***
            if value.acts_like?(:time)
              zone_conversion_method = ActiveRecord::Base.default_timezone == :utc ? :getutc : :getlocal

              if value.respond_to?(zone_conversion_method)
                value = value.send(zone_conversion_method)
              end
            end

            "'#{value.to_s(:db)}'"
          else
            super
          end
        end
      end
    end
  end

  #
  # Original code is the following URL.
  #
  #   https://github.com/rails/rails/blob/v5.0.0/activerecord/lib/active_record/relation/where_clause_factory.rb#L9
  #
  class Relation
    class WhereClauseFactory

      def build(opts, other)
        binds = []

        case opts
        when String, Array
          parts = [klass.send(:sanitize_sql, other.empty? ? opts : ([opts] + other))]
        when Hash
          opts = ActiveRecord::MonkeyPatch.adjust_timezone_offset(opts)

          attributes = predicate_builder.resolve_column_aliases(opts)
          attributes = klass.send(:expand_hash_conditions_for_aggregates, attributes)
          attributes.stringify_keys!

          attributes, binds = predicate_builder.create_binds(attributes)

          parts = predicate_builder.build_from_hash(attributes)
        when Arel::Nodes::Node
          parts = [opts]
          binds = other
        else
          raise ArgumentError, "Unsupported argument type: #{opts} (#{opts.class})"
        end

        WhereClause.new(parts, binds)
      end
    end
  end

  #
  # Original code is the following URL.
  #
  #   https://github.com/rails/rails/blob/v5.0.0/activerecord/lib/active_record/statement_cache.rb#L83
  #
  class StatementCache # :nodoc:
    class BindMap # :nodoc:
      def bind(values)
        values = ActiveRecord::MonkeyPatch.adjust_timezone_offset(values)

        bas = @bound_attributes.dup
        @indexes.each_with_index { |offset,i| bas[offset] = bas[offset].with_cast_value(values[i]) }
        bas
      end
    end
  end
end
