require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

task :default => [:spec, :lint]
RSpec::Core::RakeTask.new
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send("disable_only_variable_string")
