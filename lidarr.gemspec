# frozen_string_literal: true

require_relative "lib/lidarr/version"

Gem::Specification.new do |spec|
  spec.name = "lidarr"
  spec.version = Lidarr::VERSION
  spec.authors = ["Blake Matheny"]
  spec.email = ["bmatheny@mobocracy.net"]

  spec.summary = "A CLI for working with Lidarr"
  spec.description = "This gem provides a CLI for working with Lidarr and your music collection. It is built on top of the Lidarr API."
  spec.homepage = "https://github.com/bmatheny/lidarr-cli"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bmatheny/lidarr-cli"
  spec.metadata["changelog_uri"] = "https://github.com/bmatheny/lidarr-cli/commits/main"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features|sig)/|\.(?:git|travis|circleci|rspec|standard)|appveyor|README|CODE_OF_CONDUCT|Rakefile)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.20"
  spec.add_dependency "mustache", "~> 1.1.1"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_development_dependency "aruba", "~> 2.1"
  spec.add_development_dependency "cucumber", "~> 8.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
