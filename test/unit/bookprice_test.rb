#!/usr/bin/env ruby

require 'test_helper'

class BookpriceTest < ActiveSupport::TestCase
  test "price for corporate chanakya" do
    configatron.temp(:store_timeout => 10) do
      stores = Hash[ Bookprice.new(:isbn => "9788184951332").perform ]
      assert_equal(233.75                   , stores[:a1books][:price]    , "a1books"    ) if stores.include?(:a1books)
      assert_equal(220.0                    , stores[:bookadda][:price]   , "bookadda"   ) if stores.include?(:bookadda)
      assert_equal(250.0                    , stores[:coralhub][:price]   , "coralhub"   ) if stores.include?(:coralhub)
      assert_equal(193.0                    , stores[:flipkart][:price]   , "flipkart"   ) if stores.include?(:flipkart)
      assert_equal(165.0                    , stores[:indiaplaza][:price] , "indiaplaza" ) if stores.include?(:indiaplaza)
      assert_equal(165.0                    , stores[:infibeam][:price]   , "infibeam"   ) if stores.include?(:infibeam)
      assert_equal(192.0                    , stores[:nbcindia][:price]   , "nbcindia"   ) if stores.include?(:nbcindia)
      assert_equal(1174.0                   , stores[:pustak][:price]     , "pustak"     ) if stores.include?(:pustak)
      assert_equal(275.0                    , stores[:rediff][:price]     , "rediff"     ) if stores.include?(:rediff)
      assert_equal(193.0                    , stores[:tradus][:price]     , "tradus"     ) if stores.include?(:tradus)
      assert_equal(233.0                    , stores[:uread][:price]      , "uread"      ) if stores.include?(:uread)
    end
  end

  test "price for yoga in the workplace" do
    configatron.temp(:store_timeout => 10) do
      stores = Hash[ Bookprice.new(:isbn => "9789380032825").perform ]
      assert_equal(266.0                    , stores[:a1books][:price]    , "a1books"    ) if stores.include?(:a1books)
      assert_equal(236.0                    , stores[:bookadda][:price]   , "bookadda"   ) if stores.include?(:bookadda)
      assert_equal(263.0                    , stores[:coralhub][:price]   , "coralhub"   ) if stores.include?(:coralhub)
      assert_equal(236.0                    , stores[:flipkart][:price]   , "flipkart"   ) if stores.include?(:flipkart)
      assert_equal(204.0                    , stores[:indiaplaza][:price] , "indiaplaza" ) if stores.include?(:indiaplaza)
      assert_equal(236.0                    , stores[:infibeam][:price]   , "infibeam"   ) if stores.include?(:infibeam)
      assert_equal(236.0                    , stores[:nbcindia][:price]   , "nbcindia"   ) if stores.include?(:nbcindia)
      assert_equal(1384.0                   , stores[:pustak][:price]     , "pustak"     ) if stores.include?(:pustak)
      assert_equal(Bookprice::NOT_AVAILABLE , stores[:rediff][:price]     , "rediff"     ) if stores.include?(:rediff)
      assert_equal(Bookprice::NOT_AVAILABLE , stores[:tradus][:price]     , "tradus"     ) if stores.include?(:tradus)
      assert_equal(233.0                    , stores[:uread][:price]      , "uread"      ) if stores.include?(:uread)
    end
  end
end
