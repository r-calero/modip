require 'rubygems'

spec = Gem::Specification.new do |s|
    s.name = 'download_engine'
    s.version = '2.0.0'
    s.summary = "DownloadEngine provide a way to connect to Pubchem data base and download assays and compounds for a specific query"
    s.description = "Downloads PubChem assays and compounds through PUG REST and NCBI E-utilities."
    s.files = Dir.glob("lib/**/*.rb") + ["README", "LICENSE"]
    s.test_files = Dir.glob("test/**/*_test.rb")
    s.require_path = 'lib'
    s.author = "Romel Calero Ramos"
    s.email = "romel.calero@c3.unam.mx"

    s.add_runtime_dependency 'entrez'
    s.required_ruby_version = '>= 1.9.3'
end
