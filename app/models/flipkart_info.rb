#!/usr/bin/env ruby

class FlipkartInfo
  class << self

    def book_info(isbn)
      url = "http://www.flipkart.com/search.php?query=#{isbn}"
      page = Mechanize.new.get(url)

      product_details = page.search("div.item_details span.product_details_values")
      title     = product_details[0].text.strip
      authors   = product_details[1].text.strip
      publisher = product_details[6].text.strip
      image = nil
      image_tag = page.search("div#mprodimg-id img")
      unless image_tag.nil?
        image = image_tag.attr('src').text
      end

      {
        :info_source => "flipkart",
        :title => title,
        :authors_as_string => authors,
        :publisher => publisher,
        :image => image,
        :detail_page => url,
      }
    end

  end
end
