require "minitest/test_task"
require "rdoc/task"
require "rubygems/tasks"
require "standard/rake"

Minitest::TestTask.create

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end

Gem::Tasks.new

task default: :test
