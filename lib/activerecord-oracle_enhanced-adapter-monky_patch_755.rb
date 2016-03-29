module OracleEnhanced
  class MonkeyPatch755Railtie < ::Rails::Railtie
    ActiveSupport.on_load(:active_record) do
      require 'activerecord/monkey_patch'
    end
  end
end
