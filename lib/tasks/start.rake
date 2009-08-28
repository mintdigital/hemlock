namespace :hemlock do
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
end