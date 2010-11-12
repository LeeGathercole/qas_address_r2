set :user, "webteam"
set :group, "webteam"
set :deploy_to, "/var/www/apps/#{application}"
set :env , 'production'
role :web, "bladey"                          # Your HTTP server, Apache/etc
role :app, "bladey"                          # This may be the same as your `Web` server
# db role is actually where migrations run, therefore cap will deploy app code
# to the db server to run those migrations if you dont want the code on the db server
# and you have the correct permissions required to run migrations from your app
# server, set this to be the app server instead of the actual db server
role :db,  "bladey", :primary => true # This is where Rails migrations will run

set :branch do

  branches=`git branch -r | sed "1 d"`.split
  branches.map { | b | b.gsub!("origin/","") }
  
  puts "What branch would you like to deploy from?"
  branches.each_index do | i |
    puts((i+1).to_s + ": " + branches[i])
  end

  begin
    branch_index = Capistrano::CLI.ui.ask('Branch to deploy from?:').to_i
  end until (1..branches.size).include?(branch_index)
  
  branches[branch_index-1]

end