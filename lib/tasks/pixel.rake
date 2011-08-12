namespace :hemlock do
  namespace :pixel do
    desc 'Build HemlockPixel.swc'
    task :build => %w[
      hemlock:pixel:swc:manifest
      hemlock:pixel:swc:compile
      hemlock:pixel:swf:build
    ]

    namespace :swc do
      task :manifest do
        manifest_filename = 'manifestPixel.xml'
        xml = <<-EOS
<?xml version="1.0"?>
<componentPackage>
EOS

        includes = %w[
          com/mintdigital/hemlock
          com/mintdigital/hemlockPixel
          com/adobe
          com/dynamicflash
          com/gsolo
          com/pixelbreaker
        ]
        excludes = ["handlers", "events", "assets", "views"]
          # TODO: Remove 'events' and 'views', since widgets should now use delegate classes instead
        excludeRegexes = [
          /\._[^.]*$/, # e.g., _baseSkin.as (intended as an include)
          /.*Skin$/,
          /.*Widget/,
          /.*WidgetEvents$/,
          /.*WidgetViews$/
        ]

        # Recursively include all the files from given namespaces
        xml << includes.map do |dir|
          Dir["src/#{dir}/**/*.as"].
            map { |path| path.gsub("src/","").gsub(".as","").gsub("/",".") }.
            map do |klass|
              if  excludes.include?(klass.gsub(/.*\./,"")) ||
                  excludeRegexes.map{ |regex| klass =~ regex }.any?
                ''
              else
                <<-EOS
<component id="#{klass}" class="#{klass}"/>
EOS
              end
            end.join
        end.join

        xml << <<-EOS
</componentPackage>
EOS

        File.open("src/#{manifest_filename}","w+") do |file|
          file << xml
        end
      end # task :manifest

      task :compile do
        namespace = 'http://pixel.hemlock.mintdigital.com'
        manifest_filename = 'src/manifestPixel.xml'
        output = 'bin/HemlockPixel.swc'

        puts "Preparing #{output}..."

        compc_options = [
          "-namespace #{namespace} #{manifest_filename}",
          "-include-namespaces=#{namespace}",
          '-sp=src',
          '-sp=vendor/xiff/src',
          '-managers=flash.fonts.AFEFontManager',
          "-output=#{output}"
        ]
        `#{ENV['FLEX_SDK_HOME']}/bin/compc #{compc_options.join(' ')}`
      end # task :compile
    end # namespace :swc

    namespace :swf do
      task :build, [:debug] do |t, args|
        # Usage:
        # - `rake hemlock:pixel:swf:build`
        # - `rake hemlock:pixel:swf:build[true] (debug mode)

        # Enabling debug mode here enables Flash Player to report code line
        # numbers in error messages.

        args.with_defaults(:debug => false)

        puts "Building HemlockPixel.swf#{' (debug mode)' if args.debug}..."

        input_file  = 'com/mintdigital/hemlockPixel/HemlockPixel.as'
        output_file = 'com/mintdigital/hemlockPixel/HemlockPixel.swf'
        mxmlc_options = [
          '-compiler.source-path=.',
          '-compiler.fonts.managers=flash.fonts.AFEFontManager',
          '-compiler.include-libraries=../bin/HemlockPixel.swc',
          "-output=#{output_file}"
        ]
        mxmlc_options << '-compiler.debug=true' if args.debug

        working_dir = 'src'
        `cd #{working_dir} && #{ENV['FLEX_SDK_HOME']}/bin/mxmlc #{mxmlc_options.join(' ')} #{input_file}`
        puts "Built #{working_dir}/#{output_file}"
      end # task :build
    end # namespace :swf

  end # namespace :pixel
end
