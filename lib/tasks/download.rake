namespace :hemlock do
  namespace :download do
    desc 'Download all dependencies'
    task :all => ['hemlock:download:xiff']
    
    desc 'Download XIFF'
    task :xiff do
      puts 'Downloading XIFF...'
      
      hemlock_path = File.join(File.dirname(__FILE__), '..', '..')
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
end