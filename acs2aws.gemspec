
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acs2aws/version'

Gem::Specification.new do |spec|
  spec.name          = 'acs2aws'
  spec.version       = Acs2aws::VERSION
  spec.authors       = ['borisding']
  spec.email         = ['lding@sequoiacap.com']

  spec.summary       = 'Login and retrieve AWS STS using a any SAML IDP.'
  spec.description   = 'Login and retrieve AWS STS Token using a any SAML IDP. Inspired by OAuth2WebServerFlow.'
  spec.homepage      = 'https://github.com/borisding1994/acs2aws'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise StandardError.new('RubyGems 2.0 or newer is required to protect against public gem pushes.')
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-iam', '~> 1.5'
  spec.add_dependency 'clamp', '~> 1.3'
  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'launchy', '~> 2.4', '>= 2.4.3'
  spec.add_dependency 'nokogiri', '~> 1.8', '>= 1.8.4'
  spec.add_dependency 'puma', '~> 3.11', '>= 3.11.4'
  spec.add_dependency 'rack', '~> 2.0', '>= 2.0.5'
  spec.add_dependency 'sinatra', '~> 2.0', '>= 2.0.3'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
