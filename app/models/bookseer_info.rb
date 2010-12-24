#!/usr/bin/env ruby

require 'cgi'

class BookseerInfo
  class << self

    def link(bookinfo)
      if bookinfo.nil?
        "http://bookseer.com"
      else
        title = CGI.escape(bookinfo[:title] || "")
        authors = CGI.escape(bookinfo[:authors_as_string] || "")
        "http://bookseer.com/?title=#{title}&author=#{authors}"
      end
    end

  end
end
