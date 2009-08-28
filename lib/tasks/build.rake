namespace :hemlock do
  namespace :build do
    desc 'Build DrawingDemo app'
    task :drawingDemo, [:debug] do |t, args|
      # Usage:
      # - `rake hemlock:build:drawingDemo`
      # - `rake hemlock:build:drawingDemo[true] (debug mode)

      # Enabling debug mode here enables Flash Player to report code line
      # numbers in error messages. To get debug output in your Hemlock app via
      # DebugWidget, use the `debug` flag in environment.as instead.

      args.with_defaults(:debug => false)

      puts "Building DrawingDemo#{' (debug mode)' if args.debug}..."

      input_file = 'com/mintdigital/drawingDemo/containers/DrawingDemoContainer.as'
      output_file = 'com/mintdigital/drawingDemo/containers/DrawingDemoContainer.swf'
      mxmlc_options = [
        '-compiler.source-path=.',
        '-compiler.fonts.managers=flash.fonts.AFEFontManager',
        '-compiler.include-libraries=../bin/HemlockCore.swc',
        "-output=#{output_file}"
      ]
      mxmlc_options << '-compiler.debug=true' if args.debug

      `cd src && #{ENV['FLEX_SDK_HOME']}/bin/mxmlc #{mxmlc_options.join(' ')} #{input_file}`
      puts "Built #{output_file}"
    end

    desc 'Build HemlockCore.swc'
    task :core => ['hemlock:core:build']

    desc 'Build HemlockLoaders.swc'
    task :loaders => ['hemlock:loaders:build']
  end
end