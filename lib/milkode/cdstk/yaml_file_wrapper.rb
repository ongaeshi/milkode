# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'yaml'
require 'milkode/common/dbdir'
require 'milkode/cdstk/milkode_yaml'

module Milkode
  class YamlFileWrapper
    class YAMLAlreadyExist < RuntimeError ; end
    class YAMLNotExist < RuntimeError     ; end

    def self.yaml_file(path)
      Dbdir.yaml_path(path)
    end

    def self.create(path = ".")
      yf = yaml_file(path)
      raise YAMLAlreadyExist.new if FileTest.exist? yf
      obj = YamlFileWrapper.new(yf, MilkodeYaml.new)
      obj.save
      return obj
    end

    def self.load(path = ".")
      yf = yaml_file(path)
      raise YAMLNotExist.new unless FileTest.exist? yf
      open(yf) do |f|
        return YamlFileWrapper.new(yf, MilkodeYaml.new(f.read()))
      end
    end

    def self.load_if(path = ".")
      begin
        load(path)
      rescue YAMLNotExist
        nil
      end
    end

    def initialize(yaml_file, data)
      @yaml_file = yaml_file
      @data = data
      migrate
    end

    def contents
      @data.contents
    end

    def find_name(name)
      @data.find_name(name)
    end

    def find_dir(dir)
      @data.find_dir(dir)
    end

    def add(package)
      @data.add package
    end

    def update(package)
      @data.update package
    end

    def remove(package)
      @data.remove package
    end

    def save
      open(@yaml_file, "w") { |f| f.write(@data.dump) }
    end

    def version
      @data.version
    end

    def migrate
      if (@data.migrate)
        puts "milkode.yaml is old '#{version}'. Convert to '#{MilkodeYaml::MILKODE_YAML_VERSION}'."
        save
      end
    end
  end
end
