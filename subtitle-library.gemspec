Gem::Specification.new do |s|
  s.name = "subtitle-library"
  s.version = "0.0.1"
  s.author = "HaNdyMaN89"
  s.email = "tony.rizov@gmail.com"
  s.homepage = "https://github.com/HaNdyMaN89/subtitle-library"
  s.files = [
  "lib/subtitle-library.rb",
  "lib/subtitle-library/cue.rb",
  "lib/subtitle-library/reader.rb",
  "lib/subtitle-library/regex-patterns.rb",
  "lib/subtitle-library/changer.rb",
  "lib/subtitle-library/writer.rb"
  ]
  s.test_files = [
  "test/unit/reader-spec.rb",
  "test/unit/writer-spec.rb",
  "test/unit/changer-spec.rb",
  "test/integration/command-line-spec.rb"
  ]
  s.executables = ["subtitle-library"]
  s.require_paths = ["lib"]
  s.description = "A subtitle library which can manipulate SubRip, MicroDVD and SubViewer formats."
  s.summary = "A subtitle library."

  s.add_development_dependency "fakefs", [">= 0.4.0"]
  s.add_development_dependency "rspec", [">= 2"]
end  
  
