class BookController < ApplicationController
  def index
  end

  def view
    @isbn = params[:isbn]
    if Bookprice::is_isbn(@isbn)
      @stores = Rails.cache.fetch(@isbn, :expires_in => 1.day) do
        Bookprice::prices(@isbn)
      end
      @not_available = Bookprice::NOT_AVAILABLE
    else
      render :text => '404 Not Found', :status => 404
    end
  end

end
