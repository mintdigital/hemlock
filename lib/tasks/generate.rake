# Directory where your app's ActionScript lives.
GENERATE_SRC_DIR = File.join('flash', 'src', 'com', 'mintdigital', 'hemlock')

# TODO: Move ActionScript generation to a gem?

namespace :hemlock do
  namespace :generate do

    desc 'Generates a HemlockContainer and associated events and strategies'
    task :container do |t, args|
      # Usage:
      #
      # rake hemlock:generate:container Game
      # - Generates:
      #   - GENERATE_SRC_DIR/containers/GameContainer.as
      #   - GENERATE_SRC_DIR/events/GameEvent.as
      #   - GENERATE_SRC_DIR/strategies/GameEventStrategy.as

      # Create directories
      Rake::Task['hemlock:generate:source_directory'].execute
      %w[containers events strategies].each do |dir_name|
        dir = File.join(GENERATE_SRC_DIR, dir_name)
        unless File.exist?(dir)
          FileUtils.mkdir(dir)
          puts "- Created #{dir}"
        end
      end

      # Generate container file
      # ...

      # Generate event file
      # ...

      # Generate strategy file
      # ...
    end

    desc 'Generates a HemlockWidget'
    task :widget do |t, args|
      # Usage:
      #
      # rake hemlock:generate:container Game
      # - Generates:
      #   - GENERATE_SRC_DIR/containers/GameContainer.as
      #   - GENERATE_SRC_DIR/events/GameEvent.as
      #   - GENERATE_SRC_DIR/strategies/GameEventStrategy.as

      # Create source path
      Rake::Task['hemlock:generate:source_directory'].execute

      # Generate widgets directory
      dir = File.join(GENERATE_SRC_DIR, 'widgets')
      unless File.exist?(dir)
        FileUtils.mkdir(dir)
        puts "- Created #{dir}"
      end

      # Generate widget file
      # ...
    end

    desc 'Create source path'
    task :source_directory do
      dir = GENERATE_SRC_DIR
      unless File.exist?(dir)
        FileUtils.mkdir_p(dir)
        puts "- Created #{dir}"
      end
    end

  end
end