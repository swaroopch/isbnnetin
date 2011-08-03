desc "Clear cache"
namespace :cache do
  task :clear => :environment do
    Rails.cache.clear
    Rails.logger.info "Cache cleared"
  end
end
