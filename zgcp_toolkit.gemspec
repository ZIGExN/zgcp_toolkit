require_relative 'lib/zgcp_toolkit/version'

Gem::Specification.new do |spec|
  spec.name          = "zgcp_toolkit"
  spec.version       = ZgcpToolkit::VERSION
  spec.authors       = "ZIGExN VeNtura developers"
  spec.email         = "kuruma-dev@zigexn.vn"

  spec.summary       = "GCP Toolkit"
  spec.description   = "Manage essential toolset"
  spec.homepage      = "https://github.com/ZIGExN/zgcp_toolkit"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'stackdriver', '~> 0.20.1'
  spec.add_dependency 'dry-configurable', '~> 0.11.6'
  spec.add_dependency 'google-cloud-error_reporting', '~> 0.42.0'
end
