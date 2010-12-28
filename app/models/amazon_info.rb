#!/usr/bin/env ruby

raise "AWS_ACCESS_KEY not specified" if ENV['AWS_ACCESS_KEY'].nil?
raise "AWS_SECRET_KEY not specified" if ENV['AWS_SECRET_KEY'].nil?

Amazon::Ecs.options = {
  :aWS_access_key_id => ENV['AWS_ACCESS_KEY'],
  :aWS_secret_key => ENV['AWS_SECRET_KEY'],
}

class AmazonInfo
  class << self

    def book_info(isbn)
      authors       = nil
      title         = nil
      publisher     = nil
      detailpageurl = nil
      image         = nil
      source        = nil
      content       = nil
      rating        = nil
      rating_count  = nil

      result = Amazon::Ecs.item_lookup(isbn, { :response_group => 'Medium' })
      if result.has_error?
        return nil
      end

      result.items.each do |item|
        authors = item.get_array('author')
        title = item.get('title')
        publisher = item.get('publisher')
        detailpageurl = item.get('detailpageurl')
        image = item.get('largeimage/url')
        reviews = item/'editorialreview'
        unless reviews.nil?
          reviews.each do |review|
            source = Amazon::Element.get_unescaped(review, 'source')
            content = Amazon::Element.get_unescaped(review, 'content')
            break
          end
        end
        break
      end

      result = Amazon::Ecs.item_lookup(isbn, { :response_group => 'Reviews' })
      result.items.each do |item|
        rating = item.get('averagerating')
        rating_count = item.get('totalreviews')
        break
      end

      {
        :info_source => "amazon",
        :title => title,
        :authors => authors,
        :authors_as_string => authors.join(', '),
        :publisher => publisher,
        :detail_page => detailpageurl,
        :image => image,
        :review_source => source,
        :review_content => content,
        :rating => rating,
        :rating_count => rating_count,
      }
    end

  end
end
