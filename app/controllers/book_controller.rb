class BookController < ApplicationController
  include BookHelper

  respond_to :html
  respond_to :json, :only => :view

  def view
    @isbn = canonicalize_isbn(params[:isbn])
    unless @isbn.present? && (is_isbn10(@isbn) || is_isbn13(@isbn))
      render :text => 'Not Found', :status => 404
      return
    end

    if is_isbn10(@isbn)
      redirect_to :action => "view", :isbn => isbn_10_to_13(@isbn)
      return
    end

    @prices = Bookprice.new(:isbn => @isbn)

    @stores = Rails.cache.fetch(@prices.cache_key)
    if @stores.nil?
      # Check if book is already queued.
      if Delayed::Backend::Mongoid::Job.where(:handler => /#{@isbn}/).empty?
        logger.info("Book #{@isbn} has been queued")
        @prices.delay.perform
      else
        logger.info("Book #{@isbn} is already queued")
      end
    end

    @bookinfo = Rails.cache.fetch("amazon_info:#{@isbn}", :expires_in => 1.day) { AmazonInfo::book_info(@isbn) }
    if @bookinfo.nil?
      @bookinfo = Rails.cache.fetch("flipkart_info:#{@isbn}", :expires_in => 1.day) { FlipkartInfo::book_info(@isbn) }
    end

    unless @bookinfo.nil?
      @bookseer = BookseerInfo::link(@bookinfo)
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

  def is_isbn10(text)
    /^[0-9]{9}[0-9xx]$/.match(text)
  end

  def is_isbn13(text)
    /^[0-9]{13}$/.match(text)
  end

end
