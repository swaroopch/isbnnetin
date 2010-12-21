#!/usr/bin/env ruby

require 'singleton'
require 'timeout'

require 'rubygems'
require 'mechanize'

class Bookprice
  include Singleton

  TIME_FOR_EACH_SITE = 5 # seconds
  NOT_AVAILABLE = 999_999

  def find_price_at_end(text)
    text.strip!
    price = /[,\d]+(\.\d+)?$/.match(text).to_s.gsub(",","").to_f
    price > 0 ? price : NOT_AVAILABLE
  end

  def fetch_page(url)
    begin
      Timeout::timeout(TIME_FOR_EACH_SITE) do
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
    functions = self.methods.select { |name| name =~ /^search_(\w+)$/ }.sort
    # e.g. [["a1books", search_a1books], ["infibeam", search_infibeam], ["rediff", search_rediff]]
    functions.collect { |fname| [ fname.split("_")[1].to_sym, self.method(fname) ] }
  end

  def names
    self.searches.map { |name, search| name.to_s }.sort.map(&:to_sym)
  end

  def prices(isbn)
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
      text = page.search("font#book-pric/b").text
      { :price => find_price_at_end(text), :url => url }
    else
      { :price => NOT_AVAILABLE, :url => url }
    end
  end

  def search_indiaplaza(isbn)
    url = "http://www.indiaplaza.in/search.aspx?catname=Books&srchkey=sku&srchVal=#{isbn}"
    page = self.fetch_page(url)
    unless page.nil?
      text = page.search("div.tier1box2/ul/li:first-child").text
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
    url = "http://www.uread.com/search-books/#{isbn}/"
    page = self.fetch_page(url)
    unless page.nil?
      text = page.search("span.our-price").text
      { :price => find_price_at_end(text), :url => url }
    else
      { :price => NOT_AVAILABLE, :url => url }
    end
  end

  def search_tradus(isbn)
    url = "http://www.tradus.in/search/tradus_search/#{isbn}"
    page = self.fetch_page(url)
    unless page.nil?
      text = page.search("div.search_price_col label").text
      { :price => find_price_at_end(text), :url => url }
    else
      { :price => NOT_AVAILABLE, :url => url }
    end
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
  Bookprice.instance.prices(ISBN).each do |store, data|
    unless $DEBUG
      puts %|#{store} : #{data[:price]}|
    else
      puts %|#{store} : #{data[:price]}\n( #{data[:url]} )|
    end
  end
end
