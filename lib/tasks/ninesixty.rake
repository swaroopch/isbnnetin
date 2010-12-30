
logger = Logger.new(STDOUT)

namespace :ninesixty do
  desc "Update to latest 960.gs"
  task :update => :environment do
    # https://github.com/nathansmith/960-grid-system/
    ninesixty_dir = ENV['NINESIXTY_DIR'] || File.join(ENV['HOME'], "code", "960-Grid-System")
    unless File.exists?(ninesixty_dir)
      raise "Did you set NINESIXTY_DIR correctly? Can't find the 960.gs source code."
    end

    public_dir      = File.join(Rails.root, "public")
    stylesheets_dir = File.join(public_dir, "stylesheets")
    images_dir      = File.join(public_dir, "images")

    logger.info("Copying 960.gs files")

    FileUtils.cp(File.join(ninesixty_dir, 'code', 'css', '960.css'), stylesheets_dir)

    logger.info("Done")
  end
end
