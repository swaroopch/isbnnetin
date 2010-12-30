class ContentController < ApplicationController
  def index
    @names = Bookprice::names
  end

  def about
  end
end
