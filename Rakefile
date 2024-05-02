require "bundler/gem_tasks"
require "minitest/test_task"
require "rdoc/task"
require "standard/rake"

Minitest::TestTask.create

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end

task default: :test
