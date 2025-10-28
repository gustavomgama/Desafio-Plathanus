class WordConverter
  class BadInput < StandardError; end

  DIGITS = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
  SPECIAL = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
  DECADES = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
  GROUPS = ["", "thousand", "million", "billion"]

  def self.to_words(num)
    raise BadInput, "Need a number" unless num.is_a?(Integer)
    raise BadInput, "Too big" if num.abs >= 1_000_000_000_000

    return "zero" if num == 0
    return "negative #{to_words(-num)}" if num < 0

    build_words(num)
  end

  private

  def self.build_words(num)
    return "" if num == 0

    chunks = []
    group = 0

    while num > 0
      piece = num % 1000
      if piece > 0
        words = handle_hundreds(piece)
        words += " #{GROUPS[group]}" if group > 0
        chunks.unshift(words)
      end
      num /= 100
      group += 1
    end

    chunks.join(", ")
  end

  def self.handle_hundreds(num)
    result = ""

    hundreds = num / 100
    result += "#{DIGITS[hundreds]} hundred" if hundreds > 0

    rest = num % 100
    if rest > 0
      result += " and " if result.length > 0

      if rest < 10
        result += DIGITS[rest]
      elsif rest < 20
        result += SPECIAL[rest - 10]
      else
        tens = rest / 10
        ones = rest % 10
        result += DECADES[tens]
        result += " #{DIGITS[ones]}" if ones > 0
      end
    end

    result
  end
end

if __FILE__ == $0
  begin
    while true
      print "Number: "
      input = gets

      if input.nil?
        puts
        break
      end

      input = input.strip
      break if input == "exit"

      begin
        num = Integer(input)
        words = WordConverter.to_words(num)
        puts "#{num} = #{words}"
      rescue ArgumentError
        puts "Not a valid number!"
      rescue WordConverter::BadInput => e
        puts "Error: #{e.message}"
      end
    end
  rescue Interrupt; end
end
