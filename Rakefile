# frozen_string_literal: true

require "bundler/gem_tasks"
require "cucumber"
require "cucumber/rake/task"
require "rspec/core/rake_task"
require "standard/rake"

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = ["--format pretty", "--publish-quiet"]
end

task default: :test

desc "Run all functional and unit tests along with linter"
task test: [:cucumber, :spec, :standard]
