require 'yaml'
require 'ftools'
require 'fileutils'

task :default => 'hemlock:test:default'
namespace :hemlock do
  
  namespace :download do
    desc 'Download all dependencies'
    task :all => ['hemlock:download:xiff']
    
    desc 'Download XIFF'
    task :xiff do
      puts 'Downloading XIFF...'
      
      hemlock_path = File.dirname(__FILE__)
      download_path = File.join(hemlock_path, 'tmp')
      local_source_path = File.join(hemlock_path, 'vendor')
      remote_source_uri = 'http://download.igniterealtime.org/xiff/xiff_3_0_0-beta1.zip'
      source_archive_filename = remote_source_uri.split('/').last
      source_path_parts = %w(org jivesoftware xiff)
      
      # Check for existing local source
      if File.directory?(File.join(local_source_path, 'xiff'))
        raise 'You already downloaded XIFF!: ' +
              File.join(local_source_path, *source_path_parts) and return
      end
      
      # Download file
      Dir.mkdir(download_path) unless File.directory?(download_path)
      Dir.chdir(download_path)
      `curl -O #{remote_source_uri}`
      
      # TODO: Handle network errors
      
      # Unarchive file
      `unzip #{source_archive_filename}`
      File.delete(source_archive_filename)
      
      # Move to local_source_path
      File.makedirs(local_source_path) unless File.directory?(local_source_path)
      Dir.chdir(local_source_path)
      File.move File.join(download_path, 'xiff'), File.join(local_source_path)
      
      # Clean up
      FileUtils.rm_rf File.join(download_path, 'xiff')
      Dir.rmdir(download_path) if (Dir.entries(download_path) - ['.', '..']).empty?
    end
  end
  
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
      options = {
        '-compiler.source-path' => '.',
        '-compiler.fonts.managers' => 'flash.fonts.AFEFontManager',
        '-compiler.include-libraries' => '../bin/HemlockCore.swc',
        '-output' => output_file
      }
      options.merge!('-compiler.debug' => 'true') if args.debug
      
      `cd src && #{ENV['FLEX_SDK_HOME']}/bin/mxmlc #{options.map{ |k,v| "#{k}=#{v}" }.join(' ')} #{input_file}`
      puts "Built #{output_file}"
    end
  end
  
  task :default => 'hemlock:start:all'
  namespace :start do
    desc 'Start all server components'
    task :all => ['hemlock:start:policyd']

    desc 'Start policy file daemon'
    task :policyd do |t, args|
      exec './script/flashpolicyd.pl --file=public/crossdomain.xml --port=8040 &'
    end
    
    # More starters here...
  end
  
  desc 'Deploy to staging or production'
  task :deploy, [:environment] do |t, args|
    args.with_defaults(:environment => 'staging')
    
    if !%w(staging production).include?(args.environment) then return end
      
    # TODO: If any step fails, show error message and exit
    
    source_dir = 'src'
    config_dir = "#{source_dir}/config"
    deploy_config = YAML.load_file(config_dir + '/deploy.yml')[args.environment]
    
    # Prepare environment
    # - Requires environment.as-staging or environment.as-production
    `mv #{config_dir}/environment.as #{config_dir}/environment.as-orig`
    `cp #{config_dir}/environment.as-#{args.environment} #{config_dir}/environment.as`
    
    # Compile with proper -compiler.debug flag
    Rake::Task['hemlock:compile'].invoke(deploy_config['source_app'], deploy_config['debug'])

    # scp to server
    puts 'Transferring to server...'
    `scp #{source_dir}/#{deploy_config['source_app']}.swf #{deploy_config['username']}@#{deploy_config['server']}:#{deploy_config['public_dir']}`

    # Reset environment
    `mv #{config_dir}/environment.as-orig #{config_dir}/environment.as`
  end
  
  namespace :test do
  
    desc 'Run tests'
    task :default => ["setup_test_dir", "generate_tests", "generate_package_suites", "generate_suite", "compile_tests", "run_tests"]
    task :with_debugger => ["setup_test_dir", "generate_tests", "generate_package_suites", "generate_suite", "compile_tests", "run_with_debugger"]
    
    desc "Create test dirs"
    task :setup_test_dir do
      unless File.exists?(File.dirname(__FILE__) + "/src/generated_tests")
        Dir.mkdir(File.dirname(__FILE__) + "/src/generated_tests")
        Dir.mkdir(File.dirname(__FILE__) + "/src/generated_tests/com")
        Dir.mkdir(File.dirname(__FILE__) + "/src/generated_tests/com/mintdigital")
      end
    
      Dir[File.dirname(__FILE__) + '/src/tests/com/mintdigital/**'].each do |d|
        unless File.exists?(d.gsub(/tests/, "generated_tests"))
          Dir.mkdir(d.gsub(/tests/, "generated_tests"))
        end
      end
    end
  
    desc "Generate test files"
    task :generate_tests do
      tests = Dir[File.dirname(__FILE__) + "/src/tests/com/mintdigital/**/*Test.as"].each do |file_path|
        file_path = File.expand_path(file_path)
        
        package = File.basename(File.dirname(file_path))
        emit_dir_path = File.dirname(file_path).gsub(/tests/,"generated_tests")
        Dir.mkdir(emit_dir_path) unless File.exists?(emit_dir_path)
        
        emit_file_path = emit_dir_path + "/" + File.basename(file_path, ".as") + "Emit.as"
        
        File.open(emit_file_path, "w") do |file|
          file << <<-eot
              package generated_tests.com.mintdigital.#{package} {

              import flexunit.framework.TestCase;
              import flexunit.framework.TestSuite;
              import com.mintdigital.#{package}.*;
              import tests.com.mintdigital.mocks.*;

              public class #{File.basename(emit_file_path,".as")} extends TestCase {

                  #{File.readlines(file_path)}
              }
          }
          eot
        end
      end
    end
  
    desc "Generate package test suites"
    task :generate_package_suites do
      suites = Dir[File.dirname(__FILE__) + "/src/tests/com/mintdigital/**"].each do |dir|
        package = File.basename(dir)
        tests = Dir[dir + "/*Test.as"].collect{|f| File.basename(f)}
        emit_file_path = (dir + "/" + package.capitalize + "TestSuite.as").gsub(/tests/,"generated_tests")
      
      
        File.open(emit_file_path, "w") do |file|
          file << <<-eot
          package generated_tests.com.mintdigital.#{package} {
             import flexunit.framework.TestSuite;
             import generated_tests.com.mintdigital.#{package}.*;

             public class #{package.capitalize}TestSuite{
                public static function suite() : TestSuite{
                  var testSuite : TestSuite = new TestSuite();

            eot
          
            tests.each do |test|
              file << "testSuite.addTestSuite( #{test.gsub('.as', '')}Emit );"
            end
          
            file << <<-eot

                return testSuite;
              }
            }
          }
          eot
        end
      
      end
    end
  
    desc "Generate all tests"
    task :generate_suite do
      puts  "-"*80
      puts "Generating test suite..."
      emit_file_path = (File.dirname(__FILE__) + "/src/allTests.as")
      packages = Dir[File.dirname(__FILE__) + "/src/generated_tests/com/mintdigital/**"].collect{|d| File.basename(d)}
      suites = packages.collect{|p| p.capitalize + "TestSuite"}
    
      File.open(emit_file_path, "w") do |file|
        file << <<-eot
        package {
           import flexunit.framework.TestSuite;
        eot
      
        packages.each do |package|
          file << "import generated_tests.com.mintdigital.#{package}.*;
          "
        end

      
        file << <<-eot

           public class allTests{
              public static function suite() : TestSuite{
                var testSuite : TestSuite = new TestSuite();

          eot
        
          suites.each do |suite|
            file << "testSuite.addTest( #{suite}.suite() );"
          end
        
          file << <<-eot

              return testSuite;
            }
          }
        }
        eot
      end
      puts "- Generated."
    end
  
    desc "Compile the test suite"
    task :compile_tests do
      puts 'Compiling test suite...'
      # TODO: Make options readable; see hemlock:build:drawingDemo
      `#{ENV['FLEX_SDK_HOME']}/bin/mxmlc -compiler.include-libraries "bin/FlexUnit.swc" "bin/FlexUnitRunner.swc" -compiler.debug=true -compiler.fonts.managers=flash.fonts.AFEFontManager src/HemlockTestRunner.mxml`
    end

    desc "Open compiled tests"
    task :run_tests do
      puts 'Running test suite...'
      `open src/HemlockTestRunner.swf`
    end  
  
    desc "Debug compiled tests"
    task :run_with_debugger do
      puts 'Running test suite...'
      `fdb src/HemlockTestRunner.swf`
    end
  end # namespace :test
  
  namespace :framework do
    desc 'Build HemlockCore.swc'
    task :build => ["hemlock:framework:manifest", "hemlock:framework:compile"]

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
      manifest_filename = 'manifestCore.xml'
      output = '../bin/HemlockCore.swc'
      
      # TODO: Make options readable; see hemlock:build:drawingDemo
      `cd src && #{ENV['FLEX_SDK_HOME']}/bin/compc -namespace #{namespace} #{manifest_filename} -include-namespaces #{namespace} -sp . -sp ../vendor/xiff/src -managers flash.fonts.AFEFontManager -output #{output}`
    end
  end # namespace :framework
  
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
      manifest_filename = 'manifestLoaders.xml'
      output = '../bin/HemlockLoaders.swc'
      
      # TODO: Make options readable; see hemlock:build:drawingDemo
      `cd src && #{ENV['FLEX_SDK_HOME']}/bin/compc -namespace #{namespace} #{manifest_filename} -include-namespaces #{namespace} -sp . -sp ../vendor/xiff/src -managers flash.fonts.AFEFontManager -output #{output}`
    end
  end # namespace :loaders
  
end