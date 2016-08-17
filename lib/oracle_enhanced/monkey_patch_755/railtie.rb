module OracleEnhanced
  module MonkeyPatch755
    class Railtie < ::Rails::Railtie
      initializer 'activerecord-oracle_enhanced-adapter-monky_patch_755' do
        OracleEnhanced::MonkeyPatch755::Hooks.init
      end
    end
  end
end
