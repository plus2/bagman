# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bagman/version"

Gem::Specification.new do |s|
  s.name        = "bagman"
  s.version     = Bagman::VERSION
  s.authors     = ["Lachie Cox", "Ben Askins"]
  s.email       = ["lachiec@gmail.com", "ben.askins@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Add a bag of attributes to ActiveRecord models.}
  s.description = %q{We built Bagman for a project. We wanted fast prototyping and development, and some level of escape from the schema on relational databases.}

  s.rubyforge_project = "bagman"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
