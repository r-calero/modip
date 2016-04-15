require 'rubygems'

spec = Gem::Specification.new do |s|
s.name = 'docking'
s.version = '0.0.1'
s.summary = "Docking provide tool set for docking chemical structure"
s.files = Dir.glob("{bin,docs,lib,tests,Utilities24}/**/*")
s.test_files = Dir.glob("test/*_test.rb")
s.require_paths = ['lib', 'Utilities24']
#s.autorequire = 'docking'
s.author = "Leobel Izquierdo Alvarez"
s.email = "leobelizquierdo@gmail.cu"
s.has_rdoc = false
s.required_ruby_version = '>= 1.8.2'
end

