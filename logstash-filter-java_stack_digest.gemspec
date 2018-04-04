Gem::Specification.new do |s|
  s.name          = 'logstash-filter-java_stack_digest'
  s.version       = '0.1.1'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Logstash filter that computes a digest of Java stack traces.'
  s.description   = 'Logstash filter that computes a digest of Java stack traces.'
  s.homepage      = 'https://github.com/pismy/logstash-filter-java_stack_digest'
  s.authors       = ['Pierre Smeyers']
  s.email         = 'pierre.smeyers@gmail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_development_dependency 'logstash-devutils'
end
