module OracleEnhanced
  module MonkeyPatch755
    class Hooks
      def self.init
        ActiveSupport.on_load(:active_record) do
          require 'activerecord/monkey_patch'
        end
      end
    end
  end
end
