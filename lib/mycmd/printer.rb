# coding: utf-8

module Mycmd
  class Printer
    def initialize(result, header=false)
      @result = result
      @header = header
    end

    def print
      if @result.respond_to? :each
        set_width
        print_line(@result.fields) if @header
        @result.each(as: :array) do |row|
          print_line(row)
        end
      end
    end

    private
    def set_width
      @width = @result.fields.map{|f| f.size}
      @result.each(as: :array) do |row|
        row.each_with_index do |v,i|
          @width[i] = v.to_s.size if @width[i] < v.to_s.size
        end
      end
    end

    def print_line(line_array)
      puts line_array.map.with_index {|f,i| f.to_s.ljust(@width[i], " ")}.join("\t")
    end
  end
end