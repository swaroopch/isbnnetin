#!/usr/bin/env ruby

Amazon::Ecs.options = {
  :aWS_access_key_id => configatron.aws_access_key,
  :aWS_secret_key => configatron.aws_secret_key,
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
        raise ArgumentError, "No Amazon info available"
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
        :amazon_url => detailpageurl,
        :image => image,
        :review_source => source,
        :review_content => content,
        :rating => rating,
        :rating_count => rating_count,
      }
    end

  end
end
