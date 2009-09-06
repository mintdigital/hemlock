### Change these: ###

# ActionScript package for your app:
GENERATE_PACKAGE = 'com.myOrganization.myApp'
  # FIXME: After app is generated, determine package from dir structure

# Directory where your app's ActionScript lives:
GENERATE_SRC_DIR = File.join('flash', 'src', *(GENERATE_PACKAGE.split('.')))
  # FIXME: After app is generated, determine package from dir structure



### Do not change: ###

# Directory where Hemlock templates live:
GENERATE_TEMPLATE_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src', 'com', 'mintdigital', 'templateApp')



# TODO: Move ActionScript generation to a gem?
# TODO: Refactor to use mkdir_p in verbose mode to report changes



namespace :hemlock do
  namespace :generate do

    desc 'Generates an empty Hemlock app'
    task :app, [:package] do |t, args|
      # Usage:
      #
      #     rake hemlock:generate:app[com.myOrganization.myApp]
      #
      # Generates:
      #
      #     myApp/flash/bin/HemlockCore.swc
      #     myApp/flash/src/com/myOrganization/myApp/
      #     myApp/lib/tasks/

      if args.package.nil? || args.package.split('.').size != 3
        raise 'Usage: rake hemlock:generate:app[com.myOrganization.myApp]' and return
      end

      package = args.package
      app_name = package.split('.').last
      paths = {
        :source => {
          :core_swc     => File.join(File.dirname(__FILE__), '..', '..', 'bin', 'HemlockCore.swc'),
          :loaders_swc  => File.join(File.dirname(__FILE__), '..', '..', 'bin', 'HemlockLoaders.swc'),
          :tasks_dir    => File.join(File.dirname(__FILE__), '..', '..', 'lib', 'tasks'),
          :template_dir => File.join(File.dirname(__FILE__), '..', '..', 'src', 'com', 'mintdigital', 'templateApp')
        },
        :target => {
          :app_dir      => app_name,
          :bin_dir      => File.join(app_name, 'flash', 'bin'),
          :src_dir      => File.join(app_name, 'flash', 'src', *(package.split('.'))),
          :template_dir => File.join(app_name, 'flash', 'src', 'com', 'mintdigital', 'templateApp'),
          :tasks_dir    => File.join(app_name, 'lib', 'tasks')
        }
      }

      # Create target directories
      paths[:target].each { |key, dir_path| create_dir(dir_path) }

      # Copy Hemlock binaries
      [:core_swc, :loaders_swc].each do |swc|
        File.copy(paths[:source][swc], paths[:target][:bin_dir])
        puts "- Created #{File.join(paths[:target][:bin_dir], File.basename(paths[:source][swc]))}"
      end

      # Copy ActionScript source templates
      FileUtils.cp_r(
        File.join(paths[:source][:template_dir], '.'),
        paths[:target][:template_dir]
      )
      puts "- Created #{paths[:target][:template_dir]}"

      # Copy rake tasks
      # TODO: Replace with a separate set of template .task files
      # - Templates should have instructions on what to change
      File.copy(
        File.join(File.dirname(__FILE__), '..', '..', 'Rakefile'),
        paths[:target][:app_dir]
      )
      %w[build deploy generate loaders start test].each do |filename|
        File.copy(
          File.join(paths[:source][:tasks_dir], "#{filename}.rake"),
          paths[:target][:tasks_dir]
        )
        puts "- Created #{File.join(paths[:target][:tasks_dir], filename)}.rake"
      end

      # Show next steps
      puts "\nNext:\n\n"
      puts "    cd #{paths[:target][:app_dir]}"
      puts "    rake hemlock:generate:container[MyContainer]"
      puts "    rake hemlock:generate:widget[MyWidget]"
    end

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

      unless args.container_key
        raise 'Usage: rake hemlock:generate:container[MyContainer]' and return
      end

      container_key = args.container_key
      container_key_downcase_first = container_key.sub(/^[A-Z]/) { |s| s.downcase }

      # Prepare substitutions for all files
      substitutions = {
        :app_package    => GENERATE_PACKAGE,
        :container_key  => container_key
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
      puts "\nNext, open #{container_filename} and follow its directions."
    end

    desc 'Generates a HemlockWidget'
    task :widget, [:widget_key] do |t, args|
      # Usage:
      #
      #     rake hemlock:generate:widget[Game]
      #
      # Generates:
      #
      #     GENERATE_SRC_DIR/widgets/game/GameWidget.as
      #     GENERATE_SRC_DIR/widgets/game/GameWidgetViews.as
      #     GENERATE_SRC_DIR/widgets/game/GameWidgetEvents.as

      unless args.widget_key
        raise 'Usage: rake hemlock:generate:widget[MyWidget]' and return
      end

      widget_key = args.widget_key
      widget_key_downcase_first = widget_key.sub(/^[A-Z]/) { |s| s.downcase }

      # Prepare substitutions
      substitutions = {
        :app_package  => GENERATE_PACKAGE,
        :widget_key   => widget_key
      }
      substitutions[:widget_package] =
        "#{substitutions[:app_package]}.widgets.#{widget_key_downcase_first}"
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
        ['TemplateWidget.as',       :widget_class],
        ['TemplateWidgetViews.as',  :widget_views_class],
        ['TemplateWidgetEvents.as', :widget_events_class]
      ].each do |widget_file_data|
        generate_file(
          File.join(GENERATE_TEMPLATE_DIR, 'widgets', 'template', widget_file_data[0]),
          File.join(widget_dir_path, "#{substitutions[widget_file_data[1]]}.as"),
          substitutions
        )
      end

      # Show next steps
      widget_filename = File.join(widget_dir_path, "#{substitutions[:widget_class]}.as")
      puts "\nNext, open #{widget_filename} and follow its directions."
    end

    desc 'Create source path'
    task :source_directory, [:dir] do |t, args|
      # FIXME: Remove in favor of `create_dir`

      # Usage:
      #
      #     rake hemlock:generate:source_directory[flash/src/com/myCompany/myApp]

      args.with_defaults(:dir => GENERATE_SRC_DIR)

      dir = args.dir
      unless File.exist?(dir)
        FileUtils.mkdir_p(dir)
        puts "- Created #{dir}"
      end
    end

  end
end

def create_dir(dir)
  raise 'create_dir requires a `dir` argument.' if dir.nil?

  unless File.exist?(dir)
    FileUtils.mkdir_p(dir)
    puts "- Created #{dir}"
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