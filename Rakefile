require 'yaml'
require 'ftools'
require 'fileutils'
Dir[File.join(File.dirname(__FILE__), 'lib', 'tasks', '*.rake')].each do |file|
  load file
end

task :default => 'hemlock:help'
namespace :hemlock do
  desc 'Shows info on using Hemlock\'s rake tasks'
  task :help do
    puts
    puts 'Hemlock uses Rake to simplify common tasks. See http://hemlock-kills.com/learn for more.'
    puts
    puts 'Getting started:'
    puts '- rake hemlock:download:all       # Downloads dependencies'
    puts '- rake hemlock:start:all          # Starts required background processes'
    puts
    puts 'Example apps:'
    puts '- rake hemlock:build:drawingDemo  # Compiles DrawingDemoContainer.as'
    puts '  * You can adapt this task to compile your own Hemlock apps.'
    puts
    puts 'Advanced:'
    puts '- rake hemlock:build:core         # Re-compiles HemlockCore.swc'
    puts '- rake hemlock:build:loaders      # Re-compiles HemlockLoaders.swc'
  end
end