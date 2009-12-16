require 'rake/clean'
begin
  require 'spec/rake/spectask'
  require 'spec/stats.rb'
rescue LoadError
  puts 'To use rspec for testing you must install rspec gem:'
  puts '$ sudo gem install rspec'
  exit
end

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


desc "Run the specs under spec"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Run all specs with RCov"
Spec::Rake::SpecTask.new('specs_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,1.8/gems']
end