require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run specs.'
task :default => :spec
Rake::Task[:default].prerequisites.clear

desc 'Test the polyparent plugin.'
Rake::TestTask.new(:spec) do |t|
  t.libs << 'lib'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end

desc 'Generate documentation for the polyparent plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Polyparent'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
