require "bundler/gem_tasks"
require "rake/testtask"

# Add rspec to test task
Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

# Add cane to test task
begin
  require 'cane/rake_task'
  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality) do |cane|
  end
rescue LoadError
  warn "cane not available, quality task not provided."
end

task :default => :test