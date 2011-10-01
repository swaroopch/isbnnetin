
jQuery.runisbn = function() {

  if ((/isbn.net.in/i).test(window.location.href)) {
    alert("Please drag the link to your browser's bookmarks toolbar.");
    return;
  }

  // Check if a given string is in valid ISBN format (ISBN-10 or ISBN-13)
  function isISBN(text) {
    return (/[0-9]{9}[0-9xX]/).test(text) || (/^[0-9]{13}$/).test(text);
  }

  // Go to page showing prices
  function show_prices(isbn) {
    var url = 'http://isbn.net.in/' + isbn;
    document.location.href = url;
  }

  ///// Figure out ISBN /////
  var isbn;
  if ((/infibeam.com\/Books\/info/i).test(window.location.href)) {
    isbn = $.trim( $("b:contains('ISBN:')").next().text() );
    if (isbn.length === 0) {
      isbn = $.trim( $("b:contains('EAN:')").next().text() );
    }
  } else if ((/flipkart.com/i).test(window.location.href)) {
    isbn = $.trim( $("span:contains('ISBN:')").next().find("b h2").text() );
  } else if ((/a1books.co.in\/itemdetail/i).test(window.location.href)) {
    isbn = $.trim( $("span:contains('ISBN:')").parent().next().text() );
  } else if ((/books.rediff.com\/book\//i).test(window.location.href)) {
    isbn = $.trim( $("font:contains('ISBN:')").next().text() );
  } else if ((/indiaplaza.in\/.*\/books\/.*/i).test(window.location.href)) {
    isbn = $.trim( $($("span:contains('ISBN:')")[2]).next().text() );
  } else if ((/amazon.com/i).test(window.location.href)) {
    var node = jQuery("b:contains('ISBN-10:')");
    if (node.length) {
      isbn = jQuery.trim( node.parent().text().match(/[\dxX]+$/)[0] );
    }
  } else if ((/apress.com\/book\/view/i).test(window.location.href)) {
    isbn = $.trim( $("li:contains('ISBN10:')").text().match(/[\dxX\-]+$/)[0].replace(/-/g, "") );
  } else if ((/oreilly.com\/catalog/i).test(window.location.href)) {
    isbn = $.trim( $($("dt.isbn-10")[0]).next().text().match(/[\dxX\-]+$/)[0].replace(/-/g, "") );
  } else if ((/pragprog.com\/titles/i).test(window.location.href)) {
    isbn = $("div.stats:contains('ISBN:')").text().match(/ISBN:\s+(([\dxX\-])+)/)[1];
    isbn = $.trim( isbn.replace(/-/g, "") );
  } else if ((/nbcindia.com/i).test(window.location.href)) {
    isbn = $.trim( $("li.fixed:contains('ISBN-10')").next().text() );
  } else {
    var fulltext = document.getElementsByTagName("body")[0].innerHTML;
    var grepforisbn = fulltext.match(/ISBN.*?(\d{9}[0-9xX])/i);
    if (grepforisbn === null) {
      grepforisbn = fulltext.match(/ISBN.*?(\d{13})/i);
    }
    if (grepforisbn !== null) {
      isbn = grepforisbn[1];
    }
    if (! isISBN(isbn) ) {
      isbn = undefined;
    }
  }

  if ( typeof(isbn) !== 'undefined' || typeof(isbn_ !== 'null') ) {
    if ( isISBN(isbn) ) {
      show_prices(isbn);
    } else {
      alert("No ISBN or EAN found");
    }
  } else {
    alert("No ISBN or EAN found");
  }

};
