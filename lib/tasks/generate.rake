### Change these: ###

# ActionScript package for your app:
GENERATE_PACKAGE = 'com.mintdigital.newApp'

# Directory where your app's ActionScript lives:
GENERATE_SRC_DIR = File.join('flash', 'src', *(GENERATE_PACKAGE.split('.')))



### Do not change: ###

# Directory where Hemlock templates live:
GENERATE_TEMPLATE_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src', 'com', 'mintdigital', 'templateApp')



# TODO: Move ActionScript generation to a gem?
# TODO: Refactor to use mkdir_p in verbose mode to report changes



namespace :hemlock do
  namespace :generate do

    desc 'Generates a HemlockContainer and associated events and strategies'
    task :container, [:container_key] do |t, args|
      # Usage:
      #
      #     rake hemlock:generate:container[Game]
      #
      # Generates:
      #
      #     GENERATE_SRC_DIR/containers/GameContainer.as
      #     GENERATE_SRC_DIR/events/GameEvent.as
      #     GENERATE_SRC_DIR/strategies/GameEventStrategy.as

      raise 'Usage: rake hemlock:generate:container[AppName]' unless args.container_key

      # Prepare substitutions for all files
      substitutions = {
        :app_package => GENERATE_PACKAGE,
        :container_key => args.container_key
      }
      substitutions[:container_class] = "#{substitutions[:container_key]}Container"
      substitutions[:event_class]     = "#{substitutions[:container_key]}Event"
      substitutions[:strategy_class]  = "#{substitutions[:container_key]}EventStrategy"

      # Create directories
      Rake::Task['hemlock:generate:source_directory'].invoke
      %w[containers events strategies].each do |dir_name|
        dir_path = File.join(GENERATE_SRC_DIR, dir_name)
        unless File.exist?(dir_path)
          FileUtils.mkdir(dir_path)
          puts "- Created #{dir_path}"
        end
      end

      # Generate container file
      container_filename =
        File.join(GENERATE_SRC_DIR, 'containers', "#{substitutions[:container_class]}.as")
      generate_file(
        File.join(GENERATE_TEMPLATE_DIR, 'containers', 'TemplateAppContainer.as'),
        container_filename,
        substitutions
      )

      # Generate event file
      container_key_downcase_first =
        substitutions[:container_key].sub(/^[A-Z]/) { |s| s.downcase }
      generate_file(
        File.join(GENERATE_TEMPLATE_DIR, 'events', 'TemplateEvent.as'),
        File.join(GENERATE_SRC_DIR, 'events', "#{substitutions[:event_class]}.as"),
        substitutions.merge(
          :container_key_downcase_first => container_key_downcase_first
        )
      )

      # Generate strategy file
      generate_file(
        File.join(GENERATE_TEMPLATE_DIR, 'strategies', 'TemplateEventStrategy.as'),
        File.join(GENERATE_SRC_DIR, 'strategies', "#{substitutions[:strategy_class]}.as"),
        substitutions
      )

      # Show next steps
      puts "Next, open #{container_filename} and follow its directions."
    end

    desc 'Generates a HemlockWidget'
    task :widget, [:widget_key] do |t, args|
      # Usage:
      #
      #     rake hemlock:generate:container[Game]
      #
      # Generates:
      #
      #     GENERATE_SRC_DIR/widgets/game/GameWidget.as
      #     GENERATE_SRC_DIR/widgets/game/GameWidgetViews.as
      #     GENERATE_SRC_DIR/widgets/game/GameWidgetEvents.as

      raise 'Usage: rake hemlock:generate:widget[WidgetName]' unless args.widget_key

      widget_key = args.widget_key
      widget_key_downcase_first = widget_key.sub(/^[A-Z]/) { |s| s.downcase }

      # Prepare substitutions
      substitutions = {
        :app_package => GENERATE_PACKAGE,
        :widget_key => args.widget_key
      }
      substitutions[:widget_package] =
        [substitutions[:app_package], 'widgets', widget_key_downcase_first].join('.')
      substitutions[:widget_class]        = "#{substitutions[:widget_key]}Widget"
      substitutions[:widget_views_class]  = "#{substitutions[:widget_key]}WidgetViews"
      substitutions[:widget_events_class] = "#{substitutions[:widget_key]}WidgetEvents"

      # Create source path
      Rake::Task['hemlock:generate:source_directory'].invoke
      ['widgets', File.join('widgets', widget_key_downcase_first)].each do |dir_name|
        dir_path = File.join(GENERATE_SRC_DIR, dir_name)
        unless File.exist?(dir_path)
          FileUtils.mkdir(dir_path)
          puts "- Created #{dir_path}"
        end
      end

      # Generate widgets directory
      dir = File.join(GENERATE_SRC_DIR, 'widgets')
      unless File.exist?(dir)
        FileUtils.mkdir(dir)
        puts "- Created #{dir}"
      end

      # Generate widget files
      widget_dir_path = File.join(GENERATE_SRC_DIR, 'widgets', widget_key_downcase_first)
      [
        ['TemplateWidget.as', :widget_class],
        ['TemplateWidgetViews.as', :widget_views_class],
        ['TemplateWidgetEvents.as', :widget_events_class]
      ].each do |widget_file_data|
        generate_file(
          File.join(GENERATE_TEMPLATE_DIR, 'widgets', 'template', widget_file_data[0]),
          File.join(widget_dir_path, "#{substitutions[widget_file_data[1]]}.as"),
          substitutions
        )
      end
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