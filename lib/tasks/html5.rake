
require 'fileutils'

logger = Logger.new(STDOUT)

namespace :html5 do
  desc "Update to latest HTML5-Boilerplate"
  task :update => :environment do
    # https://github.com/paulirish/html5-boilerplate
    html5_dir = ENV['BOILERPLATE_DIR'] || File.join(ENV['HOME'], "code", "html5-boilerplate")
    unless File.exists?(html5_dir)
      raise "Did you set BOILERPLATE_DIR correctly? Can't find the HTML5-Boilerplate source code."
    end

    public_dir      = File.join(Rails.root, "public")
    stylesheets_dir = File.join(public_dir, "stylesheets")
    javascripts_dir = File.join(public_dir, "javascripts")
    images_dir      = File.join(public_dir, "images")
    layouts_dir     = File.join(Rails.root, "app", "views", "layouts")

    logger.info("Copying HTML5-Boilerplate files")

    %w[.htaccess robots.txt favicon.ico apple-touch-icon.png 404.html].each do |file|
      FileUtils.cp(File.join(html5_dir, file), public_dir)
    end

    %w[style.css handheld.css].each do |file|
      FileUtils.cp(File.join(html5_dir, "css", file), stylesheets_dir)
    end

    FileUtils.cp_r(File.join(html5_dir, "js"), javascripts_dir)
    FileUtils.cp(File.join(html5_dir, "js", "libs", "jquery-1.4.4.js"), File.join(javascripts_dir, "jquery.js"))
    FileUtils.cp(File.join(html5_dir, "js", "libs", "jquery-1.4.4.min.js"), File.join(javascripts_dir, "jquery.min.js"))

    FileUtils.cp(File.join(html5_dir, "index.html"), layouts_dir)

    logger.info("Done")
    logger.info("You have to manually merge index.html into #{layouts_dir}/application.html.erb and then delete the index.html file")
  end
end
