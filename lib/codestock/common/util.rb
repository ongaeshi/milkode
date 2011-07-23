# -*- coding: utf-8 -*-

require 'rubygems'
require 'archive/zip'
require 'fileutils'

module CodeStock
  module Util
    module_function
    
    # zipファイルを展開し、展開フォルダ名を返す
    def zip_extract(filename, dst_dir)
      FileUtils.mkdir_p dst_dir

      root_list = root_entrylist(filename)
      
      if (root_list.size == 1)
        # そのまま展開
        Archive::Zip.extract filename, dst_dir
        return root_list[0].gsub("/", "")
      else
        # ディレクトリを作ってその先で展開
        dir = File.basename(filename).sub(/.zip$/, "")
        FileUtils.mkdir_p File.join(dst_dir, dir)
        Archive::Zip.extract filename, File.join(dst_dir, dir)
        return dir
      end
    end

    def root_entrylist(filename)
      list = []
      
      Archive::Zip.open(filename) do |archive|
        archive.each do |entry|
          list << entry.zip_path if entry.zip_path.split('/').size == 1
        end
      end

      list
    end
  end
end

# -- 将来的には CodeStock に統一 ---

module Gren
  module Util
    # アルファベットと演算子で表示する数を変える
    ALPHABET_DISP_NUM = 5
    OPERATOR_DISP_NUM = 10

    def time_s(time)
      t = time.truncate
      h = t / 3600
      t = t % 3600
      m = t / 60
      t = t % 60
      t += round(time - time.prec_i, 2)
      
      if (h > 0 && m > 0)
        "#{h}h #{m}m #{t}s"
      elsif (m > 0)
        "#{m}m #{t}s"
      else
        "#{t}sec"
      end
    end
    module_function :time_s

    def round(n, d)
      (n * 10 ** d).round / 10.0 ** d
    end
    module_function :round

    def size_s(size)
      tb = 1024 ** 4
      gb = 1024 ** 3
      mb = 1024 ** 2
      kb = 1024

      if (size >= tb)
        round(size / tb.prec_f, 2).to_s + "TB"
      elsif (size >= gb)
        round(size / gb.prec_f, 2).to_s + "GB"
      elsif (size >= mb)
        round(size / mb.prec_f, 2).to_s + "MB"
      elsif (size >= kb)
        round(size / kb.prec_f, 2).to_s + "KB"
      else
        size.to_s + "Byte"
      end
    end
    module_function :size_s

    def p_classtree(c)
      unless c.is_a?(Class)
        c = c.class
      end
      
      while (true)
        puts c.name
        break if (c == Object)
        p_classtree_sub(c)
        c = c.superclass
      end
    end
    module_function :p_classtree

    def p_classtree_sub(c)
      # メソッドの一覧を得る
      group = c.public_instance_methods(false).sort.partition { |m| m =~ /\w/ }
      array = group.flatten
      operator_start_index = group[0].size
      limit = ALPHABET_DISP_NUM

      print((array.size > limit) ? "｜  " :  "↓  ")
      
      counter = 0
      array.each_with_index do |v, index|
        if (index == operator_start_index)
          limit = OPERATOR_DISP_NUM
          counter = 0
          puts
          print((array.size - index > limit) ? "｜  " : "↓  ")
        end

        if (counter >= limit)
          counter = 0
          puts
          print((array.size - index > limit) ? "｜  " : "↓  ")
        end

        print v + ", "
        counter += 1
      end
      puts
    end
    module_function :p_classtree_sub

  end
end
