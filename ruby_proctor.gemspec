Gem::Specification.new do |s|
    s.name        = 'ruby_proctor'
    s.version     = '1.0.0'
    s.summary     = "Ruby Proctor!"
    s.description = "Automated Exam Proctor Written in Ruby"
    s.authors     = ["Jason Schafer"]
    s.email       = 'jpschafer@mix.wvu.edu'
    s.homepage    = 'https://github.com/jpschafer/ruby-proctor'
    s.executables = 'ruby_proctor'
    s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  end