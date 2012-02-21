# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'yaml'
require 'pathname'
require 'milkode/common/dbdir'
require 'milkode/common/util'
require 'milkode/cdstk/milkode_yaml'

module Milkode
  class CdstkYaml
    MILKODE_YAML_VERSION = '0.2'
      
    class YAMLAlreadyExist < RuntimeError ; end
    class YAMLNotExist < RuntimeError     ; end

    def self.create(path = ".")
      yf = yaml_file(path)
      raise YAMLAlreadyExist.new if FileTest.exist? yf
      obj = CdstkYaml.new(yf, MilkodeYaml.new)
      obj.save
      return obj
    end

    def self.load(path = ".")
      yf = yaml_file(path)
      raise YAMLNotExist.new unless FileTest.exist? yf
      open(yf) do |f|
        return CdstkYaml.new(yf, MilkodeYaml.new(f.read()))
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

    # def add(package)
    #   contents.concat(dirs.map{|v|{'directory' => v, 'ignore' => []}})
    #   contents.uniq!
    # end

    # def remove(query)
    #   r = query.select_any?(contents)
    #   r.each {|v| contents.delete v}
    # end

    # def remove_dir(dir)
    #   contents.delete_if do |v|
    #     dir == v.directory
    #   end
    # end

    def save
      open(@yaml_file, "w") { |f| f.write(@data.dump) }
    end

    # def find_content(dir)
    #   contents.find do |v|
    #     dir == v.directory
    #   end
    # end

    # def package_num
    #   @data.contents.size
    # end

    # def directorys
    #   contents.map{|v|v.directory}
    # end

    def version
      @data.version
    end

    # def list(query = nil)
    #   query ? query.select_all?(contents) : contents
    # end

    # def exist?(shortname)
    #   @data.contents.find {|v| File.basename(v.directory) == shortname }
    # end

    # def cant_add_directory?(dir)
    #   contents.find {|v|
    #     v.directory != File.expand_path(dir) &&
    #     File.basename(v.directory) == File.basename(dir)
    #   }
    # end

    # def cleanup
    #   contents.delete_if do |v|
    #     if (!File.exist? v.directory)
    #       yield v if block_given?
    #       true
    #     else
    #       false
    #     end
    #   end
    # end

    # def package_root(dir)
    #   nd = Util::normalize_filename dir
    #   contents.find do |v|
    #     v if nd =~ /^#{v.directory}/
    #   end
    # end

    # def package_root_dir(dir)
    #   package = package_root(dir)
    #   (package) ? package.directory : nil
    # end

    def self.yaml_file(path)
      Dbdir.yaml_path(path)
    end

    # class Query
    #   def initialize(keywords)
    #     @keywords = keywords
    #   end

    #   def select_any?(contents)
    #     contents.find_all do |v|
    #       @keywords.any? {|s| File.basename(v.directory).include? s }
    #     end
    #   end

    #   def select_all?(contents)
    #     contents.find_all do |v|
    #       @keywords.all? {|s| File.basename(v.directory).include? s }
    #     end
    #   end
    # end

    def migrate
      if (@data.migrate)
        puts "milkode.yaml is old '#{version}'. Convert to '#{MILKODE_YAML_VERSION}'."
        save
      end
    end

    # def ignore(dir)
    #   find_content(dir)['ignore']
    # end
  end
end
