namespace :hemlock do
  namespace :loaders do
    desc 'Build HemlockLoaders.swc'
    task :build => ['hemlock:loaders:manifest', 'hemlock:loaders:compile']

    task :manifest do
      manifest_filename = 'manifestLoaders.xml'
      xml = <<-EOS
<?xml version="1.0"?>
<componentPackage>
EOS
      excludes = []
      excludeRegexes = []

      # Recursively include all the files from given namespaces
      xml << ['com/mintdigital/hemlockLoaders'].map do |dir|
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
      namespace = 'http://hemlock-loaders.mintdigital.com'
      manifest_filename = 'src/manifestLoaders.xml'
      output = 'bin/HemlockLoaders.swc'

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
  end # namespace :loaders
end