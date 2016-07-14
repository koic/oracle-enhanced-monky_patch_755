#
# This code is a monkey patch for oracle-enhanced ISSUE #755.
#
#   https://github.com/rsim/oracle-enhanced/issues/755
#
module ActiveRecord
  module MonkeyPatch
    MINIMUM_SUPPORTED_VERSION = '4.2.1'.freeze
    MAXIMUM_SUPPORTED_VERSION = '4.2.7'.freeze

    def adjust_timezone_offset(opts)
      if ActiveRecord::Base.connection_config[:adapter] != 'oracle_enhanced' ||
        Gem::Version.create(Rails.version) < Gem::Version.create(MINIMUM_SUPPORTED_VERSION) ||
        Gem::Version.create(Rails.version) > Gem::Version.create(MAXIMUM_SUPPORTED_VERSION)
        return opts
      end

      case opts
      when Array
        opts.each_with_object([]) {|v, ret|
          ret << if v.is_a?(Time) || v.is_a?(Date)
            offset = v.to_time.utc_offset

            offset.positive? ? v.to_time.ago(offset) : v.to_time.since(offset)
          else
            v
          end
        }
      when Hash
        opts.each_with_object({}) {|(c, v), ret|
          ret[c] = if v.is_a?(Time) || v.is_a?(Date)
            offset = v.to_time.utc_offset

            offset.positive? ? v.to_time.ago(offset) : v.to_time.since(offset)
          else
            v
          end
        }
      else
        opts
      end
    end

    module_function :adjust_timezone_offset
  end

  #
  # Original code is the following URL.
  #
  #   https://github.com/rails/rails/blob/v4.2.6/activerecord/lib/active_record/relation/query_methods.rb#L947
  #
  module QueryMethods
    def build_where(opts, other = [])
      case opts
      when String, Array
        [@klass.send(:sanitize_sql, other.empty? ? opts : ([opts] + other))]
      when Hash
        opts = ActiveRecord::MonkeyPatch.adjust_timezone_offset(opts)
        opts = PredicateBuilder.resolve_column_aliases(klass, opts)

        tmp_opts, bind_values = create_binds(opts)
        self.bind_values += bind_values

        attributes = @klass.send(:expand_hash_conditions_for_aggregates, tmp_opts)
        add_relations_to_bind_values(attributes)

        PredicateBuilder.build_from_hash(klass, attributes, table)
      else
        [opts]
      end
    end
  end

  #
  # Original code is the following URL.
  #
  #   https://github.com/rails/rails/blob/v4.2.6/activerecord/lib/active_record/statement_cache.rb#L81
  #
  class StatementCache # :nodoc:
    class BindMap # :nodoc:
      def bind(values)
        values = ActiveRecord::MonkeyPatch.adjust_timezone_offset(values)

        bvs = @bind_values.map { |pair| pair.dup }
        @indexes.each_with_index { |offset,i| bvs[offset][1] = values[i] }
        bvs
      end
    end
  end
end
