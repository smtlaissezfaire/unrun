require 'date'

Gem::Specification.new do |s|
  s.name        = 'unrun'
  s.version     = '0.0.1'
  s.date        = Date.today.to_s
  s.summary     = ""
  s.description = ""
  s.authors     = ["Scott Taylor"]
  s.email       = ['scott@railsnewbie.com']
  s.files       = Dir.glob("lib/**/**.rb")
  s.homepage    = 'http://github.com/smtlaissezfaire/unr'
  s.license     = 'MIT'
end
