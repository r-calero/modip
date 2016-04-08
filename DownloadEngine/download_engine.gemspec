require 'rubygems'

spec = Gem::Specification.new do |s|
    s.name = 'download_engine'
    s.version = '0.0.4'
    s.summary = "DownloadEngine provide a way to connect to Pubchem data base and download assays and compounds for a specific query"
    s.files = Dir.glob("**/**/**")
    s.test_files = Dir.glob("test/*_test.rb")
    s.require_path = 'lib'
    s.author = "Leobel Izquierdo Alvarez"
    s.email = "leobelizquierdo@gmail.com"
    s.has_rdoc = false


    s.add_runtime_dependency 'entrez'
    s.required_ruby_version = '>= 1.9.1'
end

