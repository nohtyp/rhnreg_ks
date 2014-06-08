require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint/tasks/puppet-lint'

task :default => [:spec, :lint]
RSpec::Core::RakeTask.new
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send("disable_only_variable_string")
PuppetLint.configuration.send("disable_variables_not_enclosed")
PuppetLint.configuration.send("disable_class_inherits_from_params_class")
