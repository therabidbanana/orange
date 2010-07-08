require 'rake/clean'
require 'spec/stats.rb'
begin
  require 'spec/rake/spectask'
rescue LoadError
  puts 'To use rspec for testing you must install rspec gem:'
  puts '$ sudo gem install rspec'
  exit
end

begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end


Jeweler::Tasks.new do |gemspec|
  gemspec.name = "orange"
  gemspec.summary = "Middle ground between Sinatra and Rails"
  gemspec.description = "Orange is a Ruby framework for building managed websites with code as simple as Sinatra"
  gemspec.email = "therabidbanana@gmail.com"
  gemspec.homepage = "http://github.com/therabidbanana/orange"
  gemspec.authors = ["David Haslem"]
  gemspec.files = FileList['lib/**/*']
  gemspec.test_files = FileList['spec/**/*.rb']
  gemspec.add_dependency('rack', '>= 1.0.1')
  gemspec.add_dependency('orange-core', '>= 0.5.7')
  gemspec.add_dependency('orange-more', '>= 0.5.7')
  gemspec.add_dependency('orange-sparkles', '>= 0.5.7')
  gemspec.add_development_dependency "rspec", ">= 0"
  gemspec.add_development_dependency "rack-test", ">= 0"
end
Jeweler::GemcutterTasks.new

desc "Report code statistics on the application and specs code"
task :stats do
  stats_directories = {
      "Specs" => "spec",
      "Application" => "lib"
    }.map {|name, dir| [name, "#{Dir.pwd}/#{dir}"]}
  SpecStatistics.new(*stats_directories).to_s
end

CLEAN = Rake::FileList['doc/', 'coverage/', 'db/*']

desc "Test is same as running specs"
task :test => :spec

desc "rcov is same as running specs_with_rcov"
task :rcov => :specs_with_rcov

desc "Default task is to run tests"
task :default => :spec

desc "Generate documentation with yard"
task :doc do
  sh "yardoc"
end

desc "Opens Coverage File"
task :show_cov do
  sh "open coverage/index.html"
end

desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Run all specs with RCov"
Spec::Rake::SpecTask.new('specs_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,1.8/gems,1.9/gems']
end

desc "Runs basic example"
task :serve, :server do |t, args|
  opts = {:server => 'basic'}.merge args
  cd "./examples/#{opts[:server]}"
  sh "rackup"
end