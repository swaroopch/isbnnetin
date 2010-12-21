class BookController < ApplicationController
  def index
  end

  def view
    Bookprice.instance.is_isbn(params[:isbn]) || raise(NotFound.new)

    @stores = Bookprice.instance.prices(params[:isbn])
    @not_available = Bookprice::NOT_AVAILABLE
  end

end
