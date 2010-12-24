#!/usr/bin/env ruby

class FlipkartInfo
  class << self

    def book_info(isbn)
      url = "http://www.flipkart.com/search.php?query=#{isbn}"
      page = Mechanize.new.get(url)

      product_details = page.search("div.item_details span.product_details_values")
      title     = product_details[0].text.strip
      publisher = product_details[1].text.strip
      authors   = product_details[6].text.strip

      {
        :info_source => "flipkart",
        :title => title,
        :authors_as_string => authors,
        :publisher => publisher,
      }
    end

  end
end
