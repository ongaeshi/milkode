# -*- coding: utf-8 -*-

require 'rubygems'
require 'milkode/common/archive-zip'
require 'fileutils'
require 'pathname'
require 'kconv'

module Milkode
  module Util
    module_function

    class ZipfileNotFound < RuntimeError ; end
    
    # zipファイルを展開し、展開フォルダ名を返す
    # ファイルが見つからなかった時はnilを返す
    def zip_extract(filename, dst_dir)
      raise ZipfileNotFound unless File.exist?(filename)
      
      root_list = root_entrylist(filename)
      
      if (root_list.size == 1)
        # そのまま展開
        Archive::Zip.extract filename, dst_dir
        return root_list[0].gsub("/", "")
      else
        # ディレクトリを作ってその先で展開
        dir = File.basename(filename).sub(/#{File.extname(filename)}$/, "")
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

    def relative_path(path, basedir)
      path = Pathname.new(normalize_filename path)
      basedir = Pathname.new(normalize_filename basedir)
      begin
        path.relative_path_from(basedir)
      rescue ArgumentError
        path
      end
    end

    def ruby19?
      RUBY_VERSION >= '1.9.0'
    end

    def platform_win?
      RUBY_PLATFORM =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    end

    def platform_osx?
      RUBY_PLATFORM =~ /darwin/
    end

    def shell_kcode
      if platform_win?
        Kconv::SJIS             # win7? cygwin utf8?
      else
        Kconv::UTF8
      end
    end

    def filename_to_utf8(str_from_file)
      if platform_osx?
        if (ruby19?)
          str_from_file.encode('UTF-8', 'UTF8-MAC')
        else
          str_from_file
        end
      elsif platform_win?
        Kconv.kconv(str_from_file, Kconv::UTF8)        
      else
        str_from_file
      end
    end

    def larger_than_oneline(content)
      content.count($/) > 1      
    end

    def normalize_filename(str)
      if platform_win?
        str.gsub(/\A([a-z]):/) { "#{$1.upcase}:" }
      else
        str
      end
    end

    def downcase?(str)
      str == str.downcase
    end

    # parse_gotoline(['a', '123', 'b']) #=> [['a', 'b'], 123]]
    # parse_gotoline(['a', '123', 'b', 55]) #=> [['a', 'b', '123'], 55]]
    # parse_gotoline(['a:5']) #=> [['a'], 55]]
    def parse_gotoline(words)
      if gotoline_multi?(words)
        parse_gotoline_multi(words)
      else
        [parse_gotoline_single(words)]
      end
    end

    def parse_gotoline_single(words)
      lineno = -1
      index = -1

      words.each_with_index do |v, idx|
        n = v.to_i
        if (n != 0)
          lineno = n
          index = idx
        end
      end

      if (lineno == -1)
        [words, 1]              # 行番号らしきものは見つからなかった
      else
        words.delete_at(index)
        [words, lineno]        
      end
    end

    def parse_gotoline_multi(words)
      words.map do |v|
        a = v.split(':')
        [[a[0..-2].join(':')], a[-1].to_i]
      end
    end

    def gotoline_multi?(words)
      if (words.join(" ") =~ /:\d+/)
        true
      else
        false
      end
    end

    # 'package/to/a.txt' #=> 'package', 'to/a.txt'
    # 'package'          #=> 'package', nil
    def divide_shortpath(shortpath)
      a = shortpath.split('/')

      if (a.size >= 2)
        return a[0], a[1..-1].join('/')
      else
        return a[0], nil
      end
    end

  end
end

# -- 将来的には Milkode に統一 ---

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
      t += round(time - time.to_i, 2)
      
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
        round(size / tb.to_f, 2).to_s + "TB"
      elsif (size >= gb)
        round(size / gb.to_f, 2).to_s + "GB"
      elsif (size >= mb)
        round(size / mb.to_f, 2).to_s + "MB"
      elsif (size >= kb)
        round(size / kb.to_f, 2).to_s + "KB"
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
