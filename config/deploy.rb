#hacked together for test deployment to sit env (12/11/2010) 
#@author Paul Carey <paul.carey@hdnl.co.uk>
set :stages, %w(sit production testing)
set :default_stage, "testing"
require 'capistrano/ext/multistage'
require 'capistrano/logger'
require 'hoptoad_notifier/capistrano'
require "bundler/capistrano"

#Log output of last deployment to file
output = File.new('capistrano.log',"w+")
custom_logger = Capistrano::Logger.new(:output => output)
custom_logger.level = Capistrano::Logger::TRACE
self.logger = custom_logger

set :application, "qas_address_r2"
set :repository,  "git@github.com:LeeGathercole/qas_address_r2.git"
set :scm, :git
set :deploy_via, :copy
set :copy_exclude, [".git/*", ".svn/*"]

after "deploy:setup", "deploy:set_permissions"

before "bundle:install", "deploy:install_bundler"
after "deploy", "deploy:mark_revision"
before "deploy", "deploy:set_permissions"

after "deploy", "tester"

#check works for rollbacks
#after "deploy:rollback", "deploy:mark_revision"

#after "deploy", "git:tag_branch"

namespace :git do

  desc "tags master"
  task :tag_branch, :roles => :app do
    #something like
    tag_name = "#{branch}_deployed_#{Time.now.strftime("%d/%m/%Y")}"
    puts "Please specify a tag name [#{tag_name}]:"
    new_tag_name = Capistrano::CLI.ui.ask('New deployment tag name?:')
    if !new_tag_name.blank?; tag_name = new_tag_name; end
    exec("cd #{copy_dir} && git tag \"#{tag_name}\" && git push --tags")
  end

end


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "sets permissions of deployment folders"
  task :set_permissions, :roles => :app do
    run "#{try_sudo} chown -R #{user}:#{group} #{deploy_to}"
    run "#{try_sudo} chmod -R 0664 #{deploy_to}"
    run "#{try_sudo} chmod -R o+w #{deploy_to}/shared/log"
    run "#{try_sudo} chmod -R +X #{deploy_to}"
  end
  
  desc "Update the crontab file"
  task :update_crontab, :roles => :app do
    run "cd #{release_path} && bundle exec whenever --set environment=#{env} --update-crontab #{application}"
  end

  desc "Update themes resources in public/themes"
  task :update_themes do
    run "cd #{current_path} && rake themes:cache:update"
  end

  set :bundler_ver, '1.0.2'
  desc "installs bundler"
  task :install_bundler, :roles => :app do
    run "#{try_sudo} ls"
    run "if ! gem list | grep --silent -e 'bundler.*#{bundler_ver}'; then sudo gem uninstall --ignore-dependencies --executables --all bundler; sudo gem install -y --no-rdoc --no-ri -v #{bundler_ver} bundler; fi"
  end

  task :mark_revision do
    log = "#{deploy_to}/revisions.log"
    run "(test -e #{log} || touch #{log} && chmod 666 #{log}) && " +
      "echo #{Time.now.to_s} #{branch} #{latest_revision} >> #{log};"
  end

end



Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end