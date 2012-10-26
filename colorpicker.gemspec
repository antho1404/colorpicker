lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'colorpicker/version'

Gem::Specification.new do |gem|
  gem.name          = "colorpicker"
  gem.version       = Colorpicker::VERSION
  gem.authors       = ["antho1404"]
  gem.email         = ["anthony.estebe@gmail.com"]
  gem.description   = %q{A HTML5 color picker }
  gem.summary       = %q{A simple color picker packaged for Rails 3.1+ using asset pipeline}
  gem.homepage      = "http://github.com/antho1404/colorpicker"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
