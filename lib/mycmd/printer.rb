# coding: utf-8

module Mycmd
  class Printer
    BORDER = "*" * 30
    attr_accessor :result, :header, :width
    
    def initialize(result, header=false)
      @result = result.is_a?(Mysql2::Result) ? result_to_array(result) : result
      @header = result.is_a?(Mysql2::Result) ? result.fields : header
    end

    def print
      if @result.respond_to? :each
        set_width
        print_line(@header) if @header
        @result.each do |row|
          print_line(row)
        end
      end
    end

    private
    def result_to_array(result)
      result_array = []
      result.each(as: :array) do |row|
        result_array << row
      end
      result_array
    end

    def set_width
      @width = @header ? @header.map{|f| f.size} : Array.new(@result.first.size){0}
      @result.each do |row|
        row.each_with_index do |v,i|
          @width[i] = v.to_s.size if @width[i] < v.to_s.size
        end
      end
    end

    def print_line(line_array)
      puts line_array.map.with_index {|f,i| f.to_s.ljust(@width[i], " ")}.join("\t")
    end

    class << self
      def print_title(title, empty_line=false)
        puts if empty_line
        puts "#{BORDER}\n#{title}\n#{BORDER}"
      end
    end
  end
end