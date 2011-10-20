require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"

desc "Run all rspec tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end