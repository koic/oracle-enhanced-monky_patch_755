if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 2
  require 'activerecord/monkey_patch/rails4_2'
elsif Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR == 0
  require 'activerecord/monkey_patch/rails5_0'
elsif Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR == 1
  require 'activerecord/monkey_patch/rails5_1'
else
  raise "Unsupported version of Active Record: #{Rails.version}"
end

#
# This code is a monkey patch for oracle-enhanced ISSUE #755.
#
#   https://github.com/rsim/oracle-enhanced/issues/755
#
module ActiveRecord
  module MonkeyPatch
    def adjust_timezone_offset(opts)
      if ActiveRecord::Base.connection_config[:adapter] != 'oracle_enhanced' ||
        ActiveRecord::VERSION::MAJOR != SUPPORTED_MAJOR_VERSION ||
        ActiveRecord.version < Gem::Version.create(MINIMUM_SUPPORTED_VERSION) ||
        Gem::Version.create(ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter::VERSION ) > Gem::Version.create('1.7.3')
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
