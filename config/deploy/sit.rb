set :user, "sitfabapp"
set :group, "sitfab"
role :web, "10.0.83.229"
role :app, "10.0.83.229"
role :db, "10.0.83.229" , :primary => true # This is where Rails migrations will run
set :deploy_to, "/INFFABA01/wwwroot/#{application}"
set :deploy_via, :copy
set :copy_exclude, [".git/*", ".svn/*"]
set :env , 'sit'

set :branch, "master"

#set :branch do

#  branches=`git branch -r | sed "1 d"`.split
#  branches.map { | b | b.gsub!("origin/","") }
#  branches.delete_if { |b| b.match("^master|feature|develop") }

#  puts "What branch would you like to deploy from?"
#  branches.each_index do | i |
#    puts((i+1).to_s + ": " + branches[i])
#  end

#  begin
#    branch_index = Capistrano::CLI.ui.ask('Branch to deploy from?:').to_i
#  end until (1..branches.size).include?(branch_index)

#  branches[branch_index-1]

#end