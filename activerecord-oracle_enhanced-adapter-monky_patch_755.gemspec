$:.push File.expand_path('../lib', __FILE__)

require 'oracle_enhanced/monkey_patch_755/version'

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'activerecord-oracle_enhanced-adapter-monky_patch_755'
  s.summary = 'A monkey patch for oracle-enhanced ISSUE #755.'
  s.description = 'A monkey patch for oracle-enhanced ISSUE #755.'

  s.version = OracleEnhanced::MonkeyPatch755::VERSION

  s.license = 'MIT'

  s.authors = ['Koichi ITO']
  s.email = 'koic.ito@gmail.com'
  s.homepage = 'http://github.com/koic/oracle-enhanced-monky_patch_755'

  s.files = Dir[
    'README.md',
    'lib/**/*',
    'LICENSE'
  ]
  s.require_paths = ['lib']
  s.executables = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f) }

  s.required_ruby_version = '>= 2.0.0'
  s.license = 'MIT'

  s.add_dependency 'activerecord', '>= 4.2.1', '< 5.2'
  s.add_dependency 'activerecord-oracle_enhanced-adapter', '>= 1.6.0'
  s.add_dependency 'ruby-oci8'
  s.add_development_dependency 'railties', '>= 4.2.1', '< 5.2'
  s.add_development_dependency 'rspec', '>= 3.0.0'

  s.post_install_message = <<-END
[activerecord-oracle_enhanced-adapter-monky_patch_755]
oracle-enhanced ISSUE #755 has been resolved at oracle-enhanced 1.7.3.
The best way is to use oracle-enhanced 1.7.3 or later.

Upgrade Rails 4.2 or older version to Rails 5.
See https://github.com/rsim/oracle-enhanced#upgrade-rails-42-or-older-version-to-rails-5

Also this gem doesn't support Rails 5.2 or higher.

Thank you.
END
end
