class ContentController < ApplicationController
  caches_page :index, :about

  def index
    @names = Bookprice::names
  end

  def about
  end
end
