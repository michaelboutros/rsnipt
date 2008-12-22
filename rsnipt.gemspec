Gem::Specification.new do |s|
  s.name     = "rsnipt"
  s.version  = "1.0"
  s.summary  = "A Ruby library and CLI to interact with Snipt.net."
  s.email    = "me@michaelboutros.com"
  s.homepage = "http://github.com/michaelboutros/rsnipt"
  s.description = "A Ruby library and CLI to interact with Snipt.net, whether as a user logged in or as a browser."
  s.has_rdoc = true
  s.authors  = ["Michael Boutros"]
  s.files    = ["README.rdoc", 
		"rsnipt.gemspec",
		"lib/rsnipt.rb",
		"lib/rsnipt/actions.rb", 
		"lib/rsnipt/cli.rb", 
		"lib/rsnipt/initialize.rb",
		"lib/rsnipt/snipt_struct.rb",
		"lib/rsnipt/snipts.rb",
		"examples/with_user.rb", 
		"examples/without_user.rb",
		"bin/snipt"]
		
	s.executables = [ "snipt" ]
  s.default_executable = "snipt"
  
  s.require_path = "lib"
  s.bindir = "bin"
      
  s.rdoc_options = ["--main", "Snipt"]
  s.extra_rdoc_files = ["README.rdoc"]
  
  s.add_dependency("mechanize", ["> 0.0.0"])
end