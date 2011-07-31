module BookHelper
  # http://refactormycode.com/codes/33-isbn10-to-isbn13#refactor_257
  # isbn_10_to_13("0142000280") => 9780142000281
  def isbn_10_to_13(isbn10)
      match = %r|^([0-9]{9})[0-9xX]$|.match(isbn10)
      return false if match.nil?

      substring = match[1]

      isbn10 = isbn10.chars.to_a

      sum_of_digits = 38 +
                        3 * (isbn10[0].to_i + isbn10[2].to_i + isbn10[4].to_i + isbn10[6].to_i + isbn10[8].to_i) +
                        isbn10[1].to_i + isbn10[3].to_i + isbn10[5].to_i + isbn10[7].to_i
      check_digit = (10 - (sum_of_digits % 10)) % 10

      return %|978#{substring}#{check_digit}|
    end
end
