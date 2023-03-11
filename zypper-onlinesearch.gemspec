# frozen_string_literal: true

require "zypper/onlinesearch/version"

Gem::Specification.new do |spec|
  spec.name          = "zypper-onlinesearch"
  spec.version       = Zypper::Onlinesearch::VERSION
  spec.authors       = ["Fabio Mucciante"]
  spec.email         = ["fabio.mucciante@gmail.com"]

  spec.summary       = "Zypper addon to search packages online through the openSUSE software search website."
  spec.description   = "Search for packages through the openSUSE software search website and similar."
  spec.homepage      = "https://github.com/fabiomux/zypper-onlinesearch"
  spec.license       = "GPL-3.0"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["bug_tracker_uri"] = "https://github.com/fabiomux/zypper-onlinesearch/issues"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fabiomux/zypper-onlinesearch"
  spec.metadata["changelog_uri"] = "https://freeaptitude.altervista.org/projects/zypper-onlinesearch.html#changelog"
  spec.metadata["wiki_uri"] = "https://github.com/fabiomux/zypper-onlinesearch/wiki"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "iniparse"
  spec.add_runtime_dependency "nokogiri"
end
