desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Rake::Task['test'].execute
end
