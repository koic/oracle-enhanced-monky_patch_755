module OracleEnhanced
  require 'oracle_enhanced/monkey_patch_755/hooks'

  if defined? ::Rails::Railtie
    require 'oracle_enhanced/monkey_patch_755/railtie'
  end
end
