# frozen_string_literal: true

require File.expand_path('lib/monkey/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.6.0'

  s.name         = 'monkey'
  s.version      = Monkey::VERSION
  s.summary      = 'Monkey Compilier'
  s.description  = 'Monkey Compilier is a compilier for compiling the monkey language.'
  s.authors      = ['Andi Crotwell']
  s.email        = ['awcrotwell@gmail.com']
  s.homepage     = 'http://github.com/awcrotwell/monkey'

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*.rb']
  s.test_files   = Dir['spec/**/*.rb']

  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency 'rake', '>= 12', '< 14'

  # s.add_development_dependency 'ffi_gen',  '~> 1.2.0'

  s.metadata['rubygems_mfa_required'] = 'true'
end
