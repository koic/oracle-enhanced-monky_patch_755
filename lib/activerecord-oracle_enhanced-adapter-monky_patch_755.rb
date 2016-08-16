module OracleEnhanced
  class Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do
        require 'activerecord/monkey_patch'
        require 'activerecord/monkey_patch/rails4'
      end
    end
  end

  if defined? ::Rails::Railtie
    class MonkeyPatch755Railtie < ::Rails::Railtie
      initializer 'activerecord-oracle_enhanced-adapter-monky_patch_755' do
        OracleEnhanced::Hooks.init
      end
    end
  end
end
