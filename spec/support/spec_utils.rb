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

  def create_variables
    {
      innodb_buffer_pool_size: "268435456",
      innodb_log_buffer_size: "8388608",
      innodb_additional_mem_pool_size: "16777216",
      key_buffer_size: "16777216",
      query_cache_size: "0",
      sort_buffer_size: "524288",
      read_buffer_size: "262144",
      read_rnd_buffer_size: "524288",
      join_buffer_size: "262144",
      tmp_table_size: "16777216",
      max_heap_table_size: "16777216",
      net_buffer_length: "16384",
      max_allowed_packet: "1048576",
      thread_stack: "262144"
    }
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

    def first
      @data.first
    end

    def each(params={})
      @data.each do |d|
        yield(d)
      end
    end
  end
end
