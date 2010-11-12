set :user, "fabaapp"
set :group, "faba"
role :web, "10.0.74.95"
role :app, "10.0.74.95"
role :db, "10.0.74.95" , :primary => true # This is where Rails migrations will run
set :deploy_to, "/INFFABA01/wwwroot/#{application}"

set :deploy_via, :copy
set :copy_exclude, [".git/*", ".svn/*"]
set :env , 'production'
set :branch, "master"

