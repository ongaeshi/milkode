# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'yaml'
require 'pathname'

module CodeStock
  class CdstkYaml
    class YAMLAlreadyExist < RuntimeError
    end
    
    class YAMLNotExist < RuntimeError
    end

    def self.create(path = ".")
      yf = yaml_file(path)
      raise YAMLAlreadyExist.new if FileTest.exist? yf
      obj = CdstkYaml.new(yf, {'contents' => [], 'version' => 0.1})
      obj.save
      return obj
    end

    def self.load(path = ".")
      yf = yaml_file(path)
      raise YAMLNotExist.new unless FileTest.exist? yf
      open(yf) do |f|
        return CdstkYaml.new(yf, YAML.load(f.read()))
      end
    end

    def initialize(yaml_file, data)
      @yaml_file = yaml_file
      @data = data
    end

    def add(*dirs)
      contents.push(*dirs.map{|v|{'directory' => v}})
      contents.uniq!
    end

    def remove(query)
      r = query.select(contents)
      r.each {|v| contents.delete v}
    end

    def save
      open(@yaml_file, "w") { |f| YAML.dump(@data, f) }
    end

    def contents
      @data['contents']
    end

    def directorys
      contents.map{|v|v['directory']}
    end

    def version
      @data['version']
    end

    def list(query = nil)
      query ? query.select(contents) : contents
    end

    def exist?(shortname)
      @data['contents'].find {|v| File.basename(v['directory']) == shortname }   
    end

    def cleanup
      contents.delete_if do |v|
        !File.exist?(v['directory'])
      end
    end

    def self.yaml_file(path)
      (Pathname.new(path) + 'grendb.yaml').to_s
    end

    class Query
      def initialize(keywords)
        @keywords = keywords
      end

      def select(contents)
        contents.find_all do |v|
          @keywords.any? {|s| File.basename(v['directory']).include? s }
        end
      end
    end
  end
end
