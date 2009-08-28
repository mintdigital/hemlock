namespace :hemlock do
  namespace :core do
    desc 'Build HemlockCore.swc'
    task :build => ["hemlock:core:manifest", "hemlock:core:compile"]

    task :manifest do
      manifest_filename = 'manifestCore.xml'

      xml = <<-EOS
<?xml version="1.0"?>
<componentPackage>
EOS
      excludes = ["handlers", "events", "assets", "views"]
        # TODO: Remove 'events' and 'views', since widgets should now use delegate classes instead
      excludeRegexes = [
        /\._[^.]*$/, # e.g., _baseSkin.as (intended as an include)
        /.*WidgetEvents$/,
        /.*WidgetViews$/
      ]

      # Recursively include all the files from given namespaces
      xml << ['com/mintdigital/hemlock', 'com/adobe', 'com/dynamicflash', 'com/gsolo', 'com/pixelbreaker'].map do |dir|
         Dir["src/#{dir}/**/*.as"].map{|path| path.gsub("src/","").gsub(".as","").gsub("/",".") }.map do |klass|
           if excludes.include?(klass.gsub(/.*\./,"")) || excludeRegexes.map{ |regex| klass =~ regex }.any?
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
    end

    task :compile do
      namespace = 'http://hemlock.mintdigital.com'
      manifest_filename = 'src/manifestCore.xml'
      output = 'bin/HemlockCore.swc'

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
    end
  end # namespace :core
end