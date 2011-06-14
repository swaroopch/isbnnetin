#!/usr/bin/env ruby

# https://github.com/jugend/amazon-ecs
# http://docs.amazonwebservices.com/AWSECommerceService/2010-11-01/DG/

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
        item_attributes = item.get_element('ItemAttributes')
        authors = item_attributes.get_array('Author')
        title = item_attributes.get('Title')
        publisher = item_attributes.get('Publisher')
        detailpageurl = item.get('DetailPageURL')
        image = item_attributes.get('LargeImage/URL')
        reviews = item_attributes/'EditorialReview'
        unless reviews.nil?
          reviews.each do |review|
            source = Amazon::Element.get_unescaped(review, 'Source')
            content = Amazon::Element.get_unescaped(review, 'Content')
            break
          end
        end
        break
      end

      rating = nil
      rating_count = nil
      # TODO FIXME Getting "invalid value for ItemId" error
      #result = Amazon::Ecs.item_lookup(isbn, { :response_group => 'Reviews' })
      #unless result.has_error?
        #item = result.items.first
        #rating = item.get('AverageRating')
        #rating_count = item.get('TotalReviews')
      #end

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
