### Change these: ###

# ActionScript package for your app:
GENERATE_PACKAGE = 'com.mintdigital.newApp'

# Directory where your app's ActionScript lives:
GENERATE_SRC_DIR = File.join('flash', 'src', *(GENERATE_PACKAGE.split('.')))



### Do not change: ###

# Directory where Hemlock templates live:
GENERATE_TEMPLATE_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src', 'com', 'mintdigital', 'templateApp')



# TODO: Move ActionScript generation to a gem?

namespace :hemlock do
  namespace :generate do

    desc 'Generates a HemlockContainer and associated events and strategies'
    task :container, [:app_name] do |t, args|
      # Usage:
      #
      # rake hemlock:generate:container[Game]
      # - Generates:
      #   - GENERATE_SRC_DIR/containers/GameContainer.as
      #   - GENERATE_SRC_DIR/events/GameEvent.as
      #   - GENERATE_SRC_DIR/strategies/GameEventStrategy.as

      raise 'Usage: rake hemlock:generate:container[AppName]' unless args.app_name

      # Create directories
      Rake::Task['hemlock:generate:source_directory'].execute
      %w[containers events strategies].each do |dir_name|
        dir = File.join(GENERATE_SRC_DIR, dir_name)
        unless File.exist?(dir)
          FileUtils.mkdir(dir)
          puts "- Created #{dir}"
        end
      end

      # Prepare substitutions for all files
      substitutions = {
        :package_name => GENERATE_PACKAGE,
        :app_name => args.app_name
      }
      substitutions[:container_name]  = "#{substitutions[:app_name]}Container"
      substitutions[:event_name]      = "#{substitutions[:app_name]}Event"
      substitutions[:strategy_name]   = "#{substitutions[:app_name]}EventStrategy"

      # Generate container file
      generate_file(
        File.join(GENERATE_TEMPLATE_DIR, 'containers', 'TemplateAppContainer.as'),
        File.join(GENERATE_SRC_DIR, 'containers', "#{substitutions[:container_name]}.as"),
        substitutions
      )

      # Generate event file
      app_name_downcase_first = substitutions[:app_name]
      app_name_downcase_first[0,1] = app_name_downcase_first[0,1].downcase
      generate_file(
        File.join(GENERATE_TEMPLATE_DIR, 'events', 'TemplateEvent.as'),
        File.join(GENERATE_SRC_DIR, 'events', "#{substitutions[:event_name]}.as"),
        substitutions.merge(
          :app_name_downcase_first => app_name_downcase_first
        )
      )

      # Generate strategy file
      generate_file(
        File.join(GENERATE_TEMPLATE_DIR, 'strategies', 'TemplateEventStrategy.as'),
        File.join(GENERATE_SRC_DIR, 'strategies', "#{substitutions[:strategy_name]}.as"),
        substitutions
      )
    end

    desc 'Generates a HemlockWidget'
    task :widget, [:name] do |t, args|
      # Usage:
      #
      # rake hemlock:generate:container Game
      # - Generates:
      #   - GENERATE_SRC_DIR/containers/GameContainer.as
      #   - GENERATE_SRC_DIR/events/GameEvent.as
      #   - GENERATE_SRC_DIR/strategies/GameEventStrategy.as

      raise 'Usage: rake hemlock:generate:widget[WidgetName]' unless args.name

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

def generate_file(template_filename, target_filename, substitutions)
  if File.exist?(target_filename)
    puts "- Skipped #{target_filename}; exists"
  else
    File.copy(template_filename, target_filename)
    contents = File.open(target_filename, 'r').read
    File.open(target_filename, 'w') do |file|
      substitutions.each do |key, value|
        contents.gsub!(/%%#{key}%%/, value)
      end
      file.write contents
    end
    puts "- Created #{target_filename}"
  end
end