lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zypper/onlinesearch/version'

Gem::Specification.new do |spec|
  spec.name          = "zypper-onlinesearch"
  spec.version       = Zypper::Onlinesearch::VERSION
  spec.authors       = ["Fabio Mucciante"]
  spec.email         = ["fabio.mucciante@gmail.com"]

  spec.summary       = %q{Zypper addon to search packages online through the openSUSE software search website.}
  spec.description   = %q{This is just a complement to zypper command which search for packages through the online openSUSE software search website.}
  spec.homepage      = "https://github.com/fabiomux/zypper-onlinesearch"
  spec.license       = 'GPL-3.0'

  spec.metadata      = {
    "bug_tracker_uri"   => 'https://github.com/fabiomux/zypper-onlinesearch/issues',
    "changelog_uri"     => 'https://freeaptitude.altervista.org/projects/zypper-onlinesearch.html#changelog',
    "documentation_uri" => "https://www.rubydoc.info/gems/zypper-onlinesearch/#{spec.version}",
    "homepage_uri"      => 'https://freeaptitude.altervista.org/projects/zypper-onlinesearch.html',
    #"mailing_list_uri"  => "",
    "source_code_uri"   => 'https://github.com/fabiomux/zypper-onlinesearch',
    "wiki_uri"          => 'https://github.com/fabiomux/zypper-onlinesearch/wiki'
  }
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|.github|.gitignore)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "iniparse"
end
