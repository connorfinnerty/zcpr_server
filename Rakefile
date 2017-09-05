gem 'rspec'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
task default: :spec

desc 'use rake to run tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'zipcode_parser_spec.rb'
end

desc 'use rake to run rubocop'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end
