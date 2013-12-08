require "rvm/capistrano"  
require "bundler/capistrano"

set :application, "foods"

set :repository,  "git@github.com:jinwanlin/foods.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/opt/rails-apps/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :branch, "master"

server "115.28.160.65", :app, :web, :db, :primary => true

set :user, 'jinwanlin'
set :port, 22
default_run_options[:pty] = true 

# set :rvm_ruby_string, 'ruby-1.9.3-p362'
# set :rvm_install_type, :stable
# before 'deploy:setup', 'rvm:install_rvm'

  
after "deploy:update_code", "deploy:migrate"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"
before 'bundle:install', 'customs:symlink_db_yml'
# If you are using Passenger mod_rails uncomment this:
namespace :customs do
  task :symlink_db_yml do
    run "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
  end
end

namespace :deploy do
  task :before_update do
    
  end

  task :restart, :roles => :app, :except => { :no_release => true }, :depends => [:migrate] do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  task :after_update_code, :roles => :app do
    # run "ln -s #{deploy_to}/shared/database.yml #{release_path}/config/database.yml" # this executed after assets:precompile
    # run "ln -s #{deploy_to}/shared/solr #{release_path}/solr"
    run "cd #{current_path} && bundle"
  end
  
  namespace :web do
    task :disable do
      run "ln -s #{deploy_to}/shared/maintenance.html #{deploy_to}/shared/system/maintenance.html"
    end
    
    task :enable do
      run "rm #{deploy_to}/shared/system/maintenance.html"
    end
  end
end
