# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{linefit}
  s.version                   = "0.1.0"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors                   = ["Eric Cline", "Richard Anderson"]
  s.date                      = %q{2009-06-11}
  s.description               = %q{LineFit does weighted or unweighted least-squares line fitting to two-dimensional data (y = a + b * x). (Linear Regression)}
  s.email                     = %q{escline+github@gmail.com}
  s.files                     = ["lib/linefit.rb", "examples/lrtest.rb", "README", "LICENSE", "CHANGELOG"]
  s.homepage                  = %q{http://rubygems.org/gems/linefit}
  s.platform                  = Gem::Platform::RUBY
  s.require_path              = ["lib"]
  s.rubygems_version          = %q{1.6.2}
  s.rubyforge_project         = 'linefit'
  s.has_rdoc                  = true
  s.summary                   = %q{LineFit is a linear regression math class.}

end
