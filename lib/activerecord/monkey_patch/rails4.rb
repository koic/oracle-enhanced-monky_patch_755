module ActiveRecord
  module MonkeyPatch
    MINIMUM_SUPPORTED_VERSION = '4.2.1'.freeze
    MAXIMUM_SUPPORTED_VERSION = '4.2.7'.freeze
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
