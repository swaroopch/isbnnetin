#!/usr/bin/env ruby

require 'timeout'

class Bookprice

  NOT_AVAILABLE = 999_999
  @@logger = Logger.new(STDOUT)

  attr_accessor :isbn

  def initialize(given_isbn)
    self.isbn = self.class.check_isbn(given_isbn)
  end

  # For usage with DelayedJob : Bookprice.new(:isbn => "9789380032825").perform
  def perform
    @@logger.info("Performing job for #{self.isbn}")
    prices = self.class.prices(self.isbn)
    Rails.cache.write(self.cache_key, prices)
    prices
  end

  def cache_key
    "prices:#{self.isbn}"
  end

  def number_of_stores
    self.class.searches.size
  end

  class << self

    def find_price_at_end(text)
      return NOT_AVAILABLE if text.blank?
      text.strip!
      price = /[,\d]+(\.\d+)?$/.match(text).to_s.gsub(",","").to_f
      price > 0 ? price : NOT_AVAILABLE
    end

    def fetch_page(url)
      begin
        Timeout::timeout(configatron.store_timeout) do
          return Mechanize.new.get(url)
        end
      rescue Exception => x
        puts "ERROR in fetch_page : #{url} => #{x.message}"
      else
        nil
      end
    end

    def is_isbn(text)
      /^[0-9]{9}[0-9xX]$/.match(text) or /^[0-9]{13}$/.match(text)
    end

    def searches
      # e.g. ["search_a1books", "search_infibeam", "search_rediff"]
      functions = self.methods.map(&:to_s).select { |name| name =~ /^search_(\w+)$/ }.sort
      # e.g. [[:a1books, search_a1books], [:infibeam, search_infibeam], [:rediff, search_rediff]]
      functions.collect { |fname| [ fname.split("_")[1].to_sym, self.method(fname) ] }
    end

    def names
      self.searches.map { |name, search| name.to_s }.sort.map(&:to_sym)
    end

    def check_isbn(isbn)
      isbn = isbn[:isbn] if isbn.is_a?(Hash)
      raise ArgumentError, "Invalid ISBN: #{isbn}" unless !isbn.nil? && isbn.is_a?(String) && is_isbn(isbn)
      isbn
    end

    def prices(isbn)
      isbn = check_isbn(isbn)
      self.searches.map { |name, search| [name, search.call(isbn)] }.sort_by { |p| p[1][:price] }
    end

    def search_infibeam(isbn)
      url = "http://www.infibeam.com/Books/search?q=#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("#infiPrice").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_flipkart(isbn)
      url = "http://www.flipkart.com/search.php?query=#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("span#fk-mprod-our-id").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_a1books(isbn)
      url = "http://www.a1books.co.in/searchdetail.do?a1Code=booksgoogle&itemCode=#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("a[@href='#minSellers'] span[@class=salePrice]").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_rediff(isbn)
      url = "http://books.rediff.com/book/ISBN:#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("font#book-pric b").first
        text = text.text unless text.blank?
        text = "" if text.blank?
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_indiaplaza(isbn)
      url = "http://www.indiaplaza.com/searchproducts.aspx?sn=books&q=#{isbn}&affid=110550"
      page = self.fetch_page(url)
      unless page.nil?
        begin
          text = page.search("div.ourPrice").text
        rescue
          text = nil
        end
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_nbcindia(isbn)
      url = "http://www.nbcindia.com/Search-books.asp?q=#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("div.fieldset li/font").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_pustak(isbn)
      url = "http://www.pustak.co.in/pustak/books/product?bookId=#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("span.prod_pg_prc_font").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_coralhub(isbn)
      url = "http://www.coralhub.com/SearchResults.aspx?pindex=1&cat=0&search=#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("span#ctl00_CPBody_dlSearchResult_ctl00_tblPrice").text.gsub("/-", "")
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_bookadda(isbn)
      url = "http://www.bookadda.com/search/#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("span.ourpriceredtext").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

   def search_uread(isbn)
     #url = "http://www.uread.com/search-books/#{isbn}/"
     url = "http://www.uread.com/book/isbnnetin/#{isbn}/"
     page = self.fetch_page(url)
     unless page.nil?
       text = page.search("p.our-price").text
       { :price => find_price_at_end(text), :url => url }
     else
       { :price => NOT_AVAILABLE, :url => url }
     end
   end

    def search_tradus(isbn)
      url = "http://www.tradus.in/search/tradus_search/#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("div.productPrice").first
        text = text.text unless text.blank?
        text = "" if text.blank?
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    ## NOTE Disabled because it always gives a 404
    #def search_jumadi(isbn)
      #url = "http://www.jumadi.in/#{isbn}"
      #page = self.fetch_page(url)
      #unless page.nil?
        #text = page.search("span#our_price_display").text
        #{ :price => find_price_at_end(text), :url => url }
      #else
        #{ :price => NOT_AVAILABLE, :url => url }
      #end
    #end

    def search_coinjoos(isbn)
      url = "http://www.coinjoos.com/product/books/#{isbn}/1/"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search(".flipRate").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_friendsofbooks(isbn)
      url = "http://www.friendsofbooks.com/store/index.php?main_page=advanced_search_result&search_in_description=1&keyword=#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search(".listingDescription .productSpecialPrice").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_landmark(isbn)
      url = "http://www.landmarkonthenet.com/product/SearchPaging.aspx?code=#{isbn}&type=0&num=0"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("#ctl00_ContentPlaceHolder1_rptBook_ctl00_lblsplprice").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_crossword(isbn)
      url = "http://www.crossword.in/books/search?q=#{isbn}"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search(".variant-final-price").text
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    def search_kindle(isbn)
      url = "http://www.amazon.com/s/ref=nb_sb_noss?url=node%3D1286228011&field-keywords=#{isbn}&x=0&y=0"
      page = self.fetch_page(url)
      unless page.nil?
        text = page.search("span.sr_price")
        if text.present?
          text = text.text
        end
        text = "" if text.blank?
        { :price => find_price_at_end(text), :url => url }
      else
        { :price => NOT_AVAILABLE, :url => url }
      end
    end

    ## NOTE Disabled because it always gives a 503
    #def search_cerramatter(isbn)
      #url = "http://www.cerramatter.com/Search.html?keyword1=#{isbn}"
      #page = self.fetch_page(url)
      #unless page.nil?
        #text = page.search(".productPrice").text
        #{ :price => find_price_at_end(text), :url => url }
      #else
        #{ :price => NOT_AVAILABLE, :url => url }
      #end
    #end

  end

end


if __FILE__ == $PROGRAM_NAME
  if ARGV.length == 1
    ISBN = ARGV[0]
  else
    ISBN = "9789380032825"
  end

  puts "ISBN"
  puts "#{ISBN}"

  puts "Prices"
  Bookprice::prices(ISBN).each do |store, data|
    unless $DEBUG
      puts %|#{store} : #{data[:price]}|
    else
      puts %|#{store} : #{data[:price]}\n( #{data[:url]} )|
    end
  end
end
