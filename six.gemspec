Gem::Specification.new do |s|
  s.name        = 'six'
  s.version     = `cat VERSION`
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "six"
  s.license     = 'MIT'
  s.description = "Very simple authorization gem"
  s.authors     = ["Dmitriy Zaporozhets"]
  s.email       = 'dmitriy.zaporozhets@gmail.com'
  s.files       = ["lib/six.rb", "LICENSE"]
  s.homepage    = 'https://github.com/randx/six'
end
