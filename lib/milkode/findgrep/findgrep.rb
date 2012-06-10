# -*- coding: utf-8 -*-
require 'find'
require 'milkode/findgrep/result'
require 'rubygems'
require 'termcolor'
require 'kconv'
require 'milkode/common/platform'
require 'milkode/common/grenfiletest'
require 'milkode/common/grensnip'
require 'milkode/common/util'
include Gren
require 'cgi'
require 'pathname'
require 'milkode/database/groonga_database'

module FindGrep
  class FindGrep
    Option = Struct.new(:patternsNot,
                        :patternsOr,
                        :directory,
                        :depth,
                        :ignoreCase,
                        :colorHighlight,
                        :isSilent,
                        :debugMode,
                        :packages,
                        :filePatterns,
                        :suffixs,
                        :ignoreFiles,
                        :ignoreDirs,
                        :kcode,
                        :noSnip,
                        :dbFile,
                        :groongaOnly,
                        :isMatchFile,
                        :dispHtml,
                        :matchCountLimit,
                        :keywords,
                        :gotoline)
    
    DEFAULT_OPTION = Option.new([],
                                [],
                                ".",
                                -1,
                                false,
                                false,
                                false,
                                false,
                                [],
                                [],
                                [],
                                [],
                                [],
                                Platform.get_shell_kcode,
                                false,
                                nil,
                                false,
                                false,
                                false,
                                -1,
                                [],
                                -1)
    
    class MatchCountOverError < RuntimeError ; end

    attr_reader :documents
    
    def initialize(patterns, option)
      @patterns = patterns
      @option = option
      @patternRegexps = strs2regs(patterns, @option.ignoreCase)
      @subRegexps = strs2regs(option.patternsNot, @option.ignoreCase)
      @orRegexps = strs2regs(option.patternsOr, @option.ignoreCase)
      @filePatterns = (!@option.dbFile) ? strs2regs(option.filePatterns) : []
      @ignoreFiles = strs2regs(option.ignoreFiles)
      @ignoreDirs = strs2regs(option.ignoreDirs)
      @result = Result.new(option.directory)
      open_database if (@option.dbFile)
    end

    def open_database()
      # データベースファイル
      dbfile = Pathname(File.expand_path(@option.dbFile))

      # データベース開く
      if dbfile.exist?
        if !@grndb || @grndb.closed?
          @grndb = GroongaDatabase.new
          @grndb.open_file(dbfile.to_s)
          @documents = @grndb.documents
          puts "open    : #{dbfile.to_s} open." unless @option.isSilent
        end
      else
        raise "error    : #{dbfile.to_s} not found!!"
      end
    end

    def strs2regs(strs, ignore = false)
      regs = []

      strs.each do |v|
        option = 0
        option |= Regexp::IGNORECASE if (ignore)
        regs << Regexp.new(v, option)
      end

      regs
    end

    def searchAndPrint(stdout)
      unless (@option.dbFile)
        searchFromDir(stdout, @option.directory, 0)
      else
        searchFromDB(stdout, @option.directory)
      end

      @result.time_stop
      
      if (!@option.isSilent && !@option.dispHtml)
        if (@option.debugMode)
          stdout.puts
          stdout.puts "--- search --------"
          print_fpaths stdout, @result.search_files
          stdout.puts "--- match --------"
          print_fpaths stdout, @result.match_files
          stdout.puts "--- ignore-file --------"
          print_fpaths stdout, @result.ignore_files
          stdout.puts "--- ignore-dir --------"
          print_fpaths stdout, @result.prune_dirs
          stdout.puts "--- unreadable --------"
          print_fpaths stdout, @result.unreadable_files
        end

        unless (@option.colorHighlight)
          stdout.puts
        else
          stdout.puts HighLine::REVERSE + "------------------------------------------------------------" + HighLine::CLEAR
        end

        @result.print(stdout)
      end
    end

    def pickupRecords
      raise unless @option.dbFile
      records = searchDatabase
      @result.time_stop
      records
    end

    def time_s
      Gren::Util::time_s(@result.time)
    end

    def searchFromDB(stdout, dir)
      # データベースを検索
      records = searchDatabase

      # ヒットしたレコード数
      stdout.puts "Found   : #{records.size} records." if (!@option.dispHtml && !@option.isSilent)

      # 検索にヒットしたファイルを実際に検索
      begin
        if (@option.gotoline > 0)
          records.each do |record|
            if FileTest.exist?(record.path)
              relative_path = Milkode::Util::relative_path(record.path, Dir.pwd).to_s
              line = getTextLineno(relative_path, @option.gotoline)
              stdout.puts "#{relative_path}:#{@option.gotoline}:#{line}" if (line)
              @result.match_file_count += 1
              raise MatchCountOverError if (0 < @option.matchCountLimit && @option.matchCountLimit <= @result.match_file_count)
            end
          end
        elsif (@patterns.size > 0)
          records.each do |record|
            if (@option.groongaOnly)
              searchGroongaOnly(stdout, record)
            else
              searchFile(stdout, record.path, record.path) if FileTest.exist?(record.path)
            end
          end
        else
          records.each do |record|
            path = record.path
            relative_path = Milkode::Util::relative_path(path, Dir.pwd).to_s
            stdout.puts relative_path
            @result.match_file_count += 1
            raise MatchCountOverError if (0 < @option.matchCountLimit && @option.matchCountLimit <= @result.match_file_count)
          end
        end
      rescue MatchCountOverError
      end
    end

    def getTextLineno(path, no)
      index = no - 1

      open(path, "r") do |file|
        lines = file2data(file)

        if (index < lines.size)
          lines[index]
        else
          nil
        end
      end
    end

    def searchDatabase
      @documents.search(
        :patterns  => @patterns,
        :keywords  => @option.keywords,
        :paths     => @option.filePatterns,
        :packages  => @option.packages,
        # :restpaths => ,
        :suffixs   => @option.suffixs,
        # :offset    => ,
        # :limit     => ,
      )
    end

    def searchFromDir(stdout, dir, depth)
      if (@option.depth != -1 && depth > @option.depth)
        return
      end
      
      Dir.foreach(dir) do |name|
        next if (name == '.' || name == '..')
          
        fpath = File.join(dir,name)
        fpath_disp = fpath.gsub(/^.\//, "")
        
        # 除外ディレクトリならばパス
        if ignoreDir?(fpath)
          @result.prune_dirs << fpath_disp if (@option.debugMode)
          next;
        end

        # 読み込み不可ならばパス
        unless FileTest.readable?(fpath)
          @result.unreadable_files << fpath_disp if (@option.debugMode)
          next
        end

        # ファイルならば中身を探索、ディレクトリならば再帰
        case File.ftype(fpath)
        when "directory"
          searchFromDir(stdout, fpath, depth + 1)
        when "file"
          searchFile(stdout, fpath, fpath_disp)
        end
      end
    end
    private :searchFromDir

    def print_fpaths(stdout, data)
      stdout.print data.join("\n")
      stdout.puts if data.count > 0
      stdout.puts "total: #{data.count}"
      stdout.puts
    end
    private :print_fpaths

    def ignoreDir?(fpath)
      FileTest.directory?(fpath) &&
      (GrenFileTest::ignoreDir?(File.basename(fpath)) || ignoreDirUser?(fpath))
    end
    private :ignoreDir?

    def ignoreDirUser?(fpath)
      @ignoreDirs.any? {|v| v.match File.basename(fpath) }
    end
    private :ignoreDirUser?

    def ignoreFile?(fpath)
      !correctFileUser?(fpath) ||
      GrenFileTest::ignoreFile?(fpath) ||
      ignoreFileUser?(fpath) ||
      GrenFileTest::binary?(fpath)
    end
    private :ignoreFile?

    def correctFileUser?(fpath)
      @filePatterns.empty? ||
      @filePatterns.any? {|v| v.match File.basename(fpath) }
    end
    private :correctFileUser?

    def ignoreFileUser?(fpath)
      @ignoreFiles.any? {|v| v.match File.basename(fpath) }
    end
    private :ignoreFileUser?

    def searchFile(stdout, fpath, fpath_disp)
      @result.count += 1
      @result.size += FileTest.size(fpath)

      # 除外ファイル
      if ignoreFile?(fpath)
        @result.ignore_files << fpath_disp if (@option.debugMode)
        return
      end
      
      @result.search_count += 1
      @result.search_size += FileTest.size(fpath)

      @result.search_files << fpath_disp if (@option.debugMode)

      open(fpath, "r") do |file|
        searchData(stdout, file2data(file), fpath_disp)
      end
    end
    private :searchFile

    def searchGroongaOnly(stdout, record)
      file_size = record.content.size
      
      @result.count += 1
      @result.size += file_size
      
      @result.search_count += 1
      @result.search_size += file_size
      
      @result.search_files << record.path if (@option.debugMode)

      searchData(stdout, record.content.split("\n"), record.path)
    end
    private :searchGroongaOnly

    def searchData(stdout, data, path)
      match_file = false

      data.each_with_index { |line, index|
        result, match_datas = match?(line)

        if ( result )
          unless (@option.dispHtml)
            # header = "#{path}:#{index + 1}:"
            rpath = Milkode::Util::relative_path(path, Dir.pwd).to_s
            header = "#{rpath}:#{index + 1}:"
            
            line = GrenSnip::snip(line, match_datas) unless (@option.noSnip)

            unless (@option.colorHighlight)
              stdout.puts header + line
            else
              stdout.puts HighLine::BLUE + header + HighLine::CLEAR + GrenSnip::coloring(line, match_datas)
            end
          else
            line_no = index + 1
            line = GrenSnip::snip(line, match_datas) unless (@option.noSnip)
            
            stdout.puts <<EOF
<h2><a href="../::view#{path}">#{path}</a></h2>
<pre>
#{line_no} : #{CGI.escapeHTML(line)}
</pre>
EOF
          end

          unless match_file
            @result.match_file_count += 1
            @result.match_files << path if (@option.debugMode)
            match_file = true
            break if (@option.isMatchFile)
          end

          @result.match_count += 1
         if (0 < @option.matchCountLimit && @option.matchCountLimit <= @result.match_count)
           raise MatchCountOverError
         end
        end
      }
    end
    private :searchData

    def file2data(file)
      FindGrep::file2lines(file, @option.kcode)
    end
    private :file2data
    
    def self.file2lines(file, kcode)
      data = file.read
      
      unless Milkode::Util::ruby19?
        if (kcode != Kconv::NOCONV)
          file_kcode = Kconv::guess(data)

          if (file_kcode != kcode)
            # puts "encode!! #{fpath} : #{kcode} <- #{file_kcode}"
            data = data.kconv(kcode, file_kcode)
          end
        end
      else
        # @memo ファイルエンコーディングに相違が起きている可能性があるため対策
        #       本当はファイルを開く時にエンコーディングを指定するのが正しい

        # 方法1 : 強制的にバイナリ化
        # data.force_encoding("Binary")
        # data = data.kconv(kcode)
        
        # 方法2 : 入力エンコーディングを強制的に指定
        data = data.kconv(kcode, Kconv::guess(data))
      end

      data = data.split($/)
    end
    
    def match?(line)
      match_datas = []
      @patternRegexps.each {|v| match_datas << v.match(line)}

      sub_matchs = []
      @subRegexps.each {|v| sub_matchs << v.match(line)}

      or_matchs = []
      @orRegexps.each {|v| or_matchs << v.match(line)}
      
      unless (@option.isMatchFile)
        result = match_datas.all? && !sub_matchs.any? && (or_matchs.empty? || or_matchs.any?)
      else
        result = first_condition(match_datas, sub_matchs, or_matchs)
      end
      result_match = match_datas + or_matchs
      result_match.delete(nil)

      return result, result_match
    end
    private :match?

    def first_condition(match_datas, sub_matchs, or_matchs)
      unless match_datas.empty?
        match_datas[0]
      else
        or_matchs[0]
      end
    end
  end
end
