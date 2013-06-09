Gem::Specification.new do |s|
  s.name    = 'osom-tables'
  s.version = '1.0.0'
  s.date    = '2013-06-09'

  s.summary = "Fancy ajax tables in true rails style"
  s.description = "Fancy ajax tables engine that fits rails infrastructure"

  s.authors  = ['Nikolay Nemshilov']
  s.email    = 'nemshilov@gmail.com'
  s.homepage = 'http://github.com/MadRabbit/osom-tables'
  s.licenses = ['MIT']

  s.files = Dir['lib/**/*'] + Dir['vendor/**/*']
  s.files+= %w(
    README.md
  )
end
