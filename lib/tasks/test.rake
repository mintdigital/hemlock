SRC_DIR = File.join(File.dirname(__FILE__), '..', '..', 'src')

namespace :hemlock do
  namespace :test do
  
    desc 'Run tests'
    task :default => ["setup_test_dir", "generate_tests", "generate_package_suites", "generate_suite", "compile_tests", "run_tests"]
    task :with_debugger => ["setup_test_dir", "generate_tests", "generate_package_suites", "generate_suite", "compile_tests", "run_with_debugger"]
    
    desc 'Create test directories'
    task :setup_test_dir do
      unless File.exists?(File.join(SRC_DIR, 'generated_tests'))
        Dir.mkdir(File.join(SRC_DIR, 'generated_tests'))
        Dir.mkdir(File.join(SRC_DIR, 'generated_tests/com'))
        Dir.mkdir(File.join(SRC_DIR, 'generated_tests/com/mintdigital'))
      end
    
      Dir[File.join(SRC_DIR, 'tests/com/mintdigital/**')].each do |d|
        unless File.exists?(d.gsub(/tests/, "generated_tests"))
          Dir.mkdir(d.gsub(/tests/, "generated_tests"))
        end
      end
    end
  
    desc 'Generate test files'
    task :generate_tests do
      tests = Dir[File.join(SRC_DIR, 'tests/com/mintdigital/**/*Test.as')].each do |file_path|
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
  
    desc 'Generate package test suites'
    task :generate_package_suites do
      suites = Dir[File.join(SRC_DIR, 'tests/com/mintdigital/**')].each do |dir|
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
  
    desc 'Generate all tests'
    task :generate_suite do
      puts  "-"*80
      puts "Generating test suite..."
      emit_file_path = File.join(SRC_DIR, 'allTests.as')
      packages = Dir[File.join(SRC_DIR, 'generated_tests/com/mintdigital/**')].collect{|d| File.basename(d)}
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
    end
  
    desc 'Compile the test suite'
    task :compile_tests do
      puts 'Compiling test suite...'
      mxmlc_options = [
        '-compiler.include-libraries "bin/FlexUnit.swc" "bin/FlexUnitRunner.swc"',
        '-compiler.debug=true',
        '-compiler.fonts.managers=flash.fonts.AFEFontManager'
      ]
      `#{ENV['FLEX_SDK_HOME']}/bin/mxmlc #{mxmlc_options.join(' ')} #{File.join(SRC_DIR, 'HemlockTestRunner.mxml')}`
    end

    desc 'Open compiled tests'
    task :run_tests do
      puts 'Running test suite...'
      `open #{File.join(SRC_DIR, 'HemlockTestRunner.swf')}`
    end  
  
    desc 'Debug compiled tests'
    task :run_with_debugger do
      puts 'Running test suite...'
      `fdb #{File.join(SRC_DIR, 'HemlockTestRunner.swf')}`
    end
  end
end