class RomanConverter
  class InvalidNumber < StandardError; end
  class NumberOutOfRange < StandardError; end

  SYMBOLS = [
    [1000, "M"], [900, "CM"], [500, "D"], [400, "CD"],
    [100, "C"], [90, "XC"], [50, "L"], [40, "XL"],
    [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]
  ]

  def self.to_roman(number)
    raise InvalidNumber, "Not a number" unless number.is_a?(Integer)
    raise NumberOutOfRange, "Must be 1-3999" unless (1..3999).include?(number)

    result = ""
    remaining = number

    SYMBOLS.each do |value, letter|
      times = remaining / value
      result += letter * times
      remaining -= value * times
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
        break
      end

      input = input.strip
      break if input == "exit"

      begin
        number = Integer(input)
        roman = RomanConverter.to_roman(number)
        puts "#{number} is: #{roman}"
      rescue ArgumentError
        puts "Not a valid number."
      rescue RomanConverter::InvalidNumber, RomanConverter::NumberOutOfRange => e
        puts "#{e.message}"
      end
    end
  rescue Interrupt; end
end
