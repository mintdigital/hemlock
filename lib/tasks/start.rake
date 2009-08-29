namespace :hemlock do
  desc 'Start all server components'
  task :start do
    %w[hemlock:start:policyd].each do |task|
      Rake::Task[task].execute
    end
  end

  task :default => 'hemlock:start:all'
  namespace :start do
    desc 'Start all server components'
    task :all => ['hemlock:start']
      # TODO: Phase out; use hemlock:start instead

    desc 'Start policy file daemon'
    task :policyd do |t, args|
      exec './script/flashpolicyd.pl --file=public/crossdomain.xml --port=8040 &'
    end
    
    # More starters here...
  end
end