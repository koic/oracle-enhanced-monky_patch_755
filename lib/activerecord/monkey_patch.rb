#
# This code is a monkey patch for oracle-enhanced ISSUE #755.
#
#   https://github.com/rsim/oracle-enhanced/issues/755
#
module ActiveRecord
  module MonkeyPatch
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
end
