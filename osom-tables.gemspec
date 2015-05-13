require File.expand_path('../lib/osom_tables', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'osom-tables'
  s.version = OsomTables::VERSION
  s.date    = '2013-06-09'

  s.summary = "Fancy ajax tables in true rails style"
  s.description = "Fancy ajax tables engine that fits rails infrastructure"

  s.authors  = ['Nikolay Nemshilov']
  s.email    = 'nemshilov@gmail.com'
  s.homepage = 'http://github.com/MadRabbit/osom-tables'
  s.licenses = ['MIT']

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
