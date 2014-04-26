require 'open-uri'

module Milkode
  class DummyRecord
    attr_reader :path
    attr_reader :content

    def self.from_url(url)
      URI(url).read.split.map do |path|
        DummyRecord.new(path)
      end
    end

    def initialize(path)
      @path = path
      # @content = File.read(@path)   # Need only at 'gmilk --cache'
    end
  end
end
