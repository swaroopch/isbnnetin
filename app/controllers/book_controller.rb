class BookController < ApplicationController
  respond_to :html
  respond_to :json, :only => :view

  def index
  end

  def view
    @isbn = canonicalize_isbn(params[:isbn])
    if @isbn.nil? || !is_isbn(@isbn)
      render :text => 'Not Found', :status => 404
      return
    end

    @prices = Bookprice.new(:isbn => @isbn)
    @bookinfo = Rails.cache.fetch("amazon_info:#{@isbn}", :expires_in => 1.day) { AmazonInfo::book_info(@isbn) }
    if @bookinfo.nil?
      @bookinfo = Rails.cache.fetch("flipkart_info:#{@isbn}", :expires_in => 1.day) { FlipkartInfo::book_info(@isbn) }
    end

    unless @bookinfo.nil?
      @bookseer = BookseerInfo::link(@bookinfo)

      @stores = Rails.cache.read(@prices.cache_key)
      if @stores.nil?
        @prices.delay.perform
        #Delayed::Job.enqueue(@prices)
      end
    end

    @not_available = Bookprice::NOT_AVAILABLE

    respond_with(@stores) do |format|
      format.json do
        render :json => @stores
      end
    end
  end


  private

  def canonicalize_isbn(text)
    unless text.nil?
      text.to_s.gsub('-', '').upcase
    end
  end

  def is_isbn(text)
    /^[0-9]{9}[0-9xx]$/.match(text) or /^[0-9]{13}$/.match(text)
  end

end
