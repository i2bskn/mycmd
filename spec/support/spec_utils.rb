require "stringio"

module SpecUtils
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end

  def create_result
    Result.new
  end

  class Result
    attr_reader :fields

    def initialize
      @data = [
        ["first", "one"],
        ["second", "two"],
        ["third", "three"]
      ]
      @fields = ["order", "number"]
    end

    def each(params={})
      @data.each do |d|
        yield(d)
      end
    end
  end
end
