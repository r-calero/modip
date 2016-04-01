require 'rubygems'

spec = Gem::Specification.new do |s|
s.name = 'download_engine'
s.version = '0.0.1'
s.summary = "DownloadEngine provide a way to connect to Pubhem data base and download assay whit respective compounds and info for a specific query"
s.files = Dir.glob("**/**/**")
s.test_files = Dir.glob("test/*_test.rb")
s.require_path = 'lib'
#s.autorequire = 'download_engine'
s.author = "Leobel Izquierdo Alvarez"
s.email = "l.izquierdo@lab.matcom.uh.cu"
s.has_rdoc = false
s.required_ruby_version = '>= 1.8.2'
end

