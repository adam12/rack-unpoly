require "rake/testtask"
require "rdoc/task"
require "rubygems/tasks"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/test*.rb"]
  t.verbose = true
end

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end

Gem::Tasks.new

task default: :test
