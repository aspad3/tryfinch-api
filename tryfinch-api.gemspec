# frozen_string_literal: true

require_relative 'lib/tryfinch/api/version' # Perbaikan path ke version.rb

Gem::Specification.new do |spec|
  spec.name          = 'tryfinch-api'
  spec.version       = Tryfinch::API::VERSION # Perbaiki modulnya
  spec.authors       = ['Asep']
  spec.email         = ['asep.padlilah@doterb.com']

  spec.summary       = 'tryfinch api'
  spec.description   = 'tryfinch api gem'
  spec.homepage      = 'https://app.docyt.com'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage

  # Menentukan file yang akan dimasukkan dalam gem
  spec.files = Dir.glob('{lib,bin,sig}/**/*') + ['README.md', 'Rakefile', 'tryfinch-api.gemspec']

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Tambahkan dependensi jika ada
  spec.add_dependency 'faraday', '~> 2.0'
end
