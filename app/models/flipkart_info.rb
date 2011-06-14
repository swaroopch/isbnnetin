#!/usr/bin/env ruby
# encoding: utf-8

class FlipkartInfo
  class << self

    def book_info(isbn)
      url = "http://www.flipkart.com/search.php?query=#{isbn}"
      page = Mechanize.new.get(url)

      title = nil
      authors = nil
      publisher = nil

      product_details = page.search("div#details table.fk-specs-type1 tr")
      if product_details.present?
        product_details.each do |product_detail|
          next if product_detail.children.empty?
          key = product_detail.children[0].text.strip.encode('UTF-8').gsub(":", "")
          value = product_detail.children[1].text.strip.encode('UTF-8')
          case key
          when "Book"
            title = value
          when "Author"
            authors = value
          when "Publisher"
            publisher = value
          end
        end
      else
        return nil
      end

      image = nil
      image_tag = page.search("div#mprodimg-id img")
      unless image_tag.nil?
        image = image_tag.attr('src').text.encode('UTF-8')
      end

      source = (page.search("h3.item_desc_title").try(:children).try(:first).try(:text) || '').strip.encode('UTF-8')
      content = (page.search("div.item_desc_text.description").try(:text) || '').strip.encode('UTF-8')

      {
        :info_source => "flipkart",
        :title => title,
        :authors_as_string => authors,
        :publisher => publisher,
        :image => image,
        :detail_page => url,
        :review_source => source,
        :review_content => content,
      }
    end

  end
end
