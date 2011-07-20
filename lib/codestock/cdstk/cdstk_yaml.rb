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

    def remove(*dirs)
      dirs.each {|f| contents.delete( {'directory' => f} ) }
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

    def list(query = nil, is_verbose = false)
      r = query ? query.select(contents) : contents

      if (is_verbose)
        r.map{|v| v['directory']}
      else
        r.map{|v| File.basename v['directory']}
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
        if @keywords.empty?
          contents
        else
          contents.find_all do |v|
            @keywords.any? {|s| File.basename(v['directory']).include? s }
          end
        end
      end
    end
  end
end
