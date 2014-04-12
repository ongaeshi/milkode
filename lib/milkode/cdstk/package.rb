# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/02/21

require 'milkode/common/util'

module Milkode
  class Package
    def self.create(dir, ignore=nil)
      if ignore && ignore.size > 0
        Package.new({"directory" => dir, "ignore" => ignore})
      else
        Package.new({"directory" => dir})
      end
    end

    def initialize(hash)
      @hash = hash
      normalize
    end

    def name
      if options[:name]
        options[:name]
      else
        File.basename(directory)
      end
    end

    def directory
      @hash['directory']
    end

    def ignore
      @hash['ignore'] || []
    end

    def set_ignore(ignore)
      @hash['ignore'] = ignore
    end

    def options
      @hash['options'] || {}
    end

    def set_options(options)
      @hash['options'] = options
    end

    def hash
      @hash
    end

    def migrate
      # 色々あって、ignore値はデフォルトで設定しないようにした
      # @hash['ignore'] = [] unless ignore
    end

    # 同名パッケージか？
    def same_name?(a_name)
      name == a_name
    end

    # 同値検査
    def ==(rhs)
      name == rhs.name && directory == rhs.directory && ignore == rhs.ignore
    end

    def fav?
      options[:fav] == true
    end

    def set_fav(value)
      if value
        if @hash['options']
          @hash['options'][:fav] = true
        else
          @hash['options'] = {:fav => true}
        end
      else
        @hash['options'].delete(:fav) if @hash['options']
      end
    end

    private

    def normalize
      if (Util.platform_win?)
        @hash['directory'] = Util.normalize_filename(directory)
      end
    end
    
  end
end


