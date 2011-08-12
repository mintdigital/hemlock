namespace :hemlock do
  desc 'Deploy to staging or production environments'
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

    # Build with proper -compiler.debug flag
    Rake::Task['hemlock:build:drawingDemo'].invoke(deploy_config['source_app'], deploy_config['debug'])

    # scp to server
    puts 'Transferring to server...'
    `scp #{source_dir}/#{deploy_config['source_app']}.swf #{deploy_config['username']}@#{deploy_config['server']}:#{deploy_config['public_dir']}`

    # Reset environment
    `mv #{config_dir}/environment.as-orig #{config_dir}/environment.as`
  end
end