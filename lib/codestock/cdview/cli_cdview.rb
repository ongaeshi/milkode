# -*- coding: utf-8 -*-
require 'optparse'
require 'codestock/findgrep/findgrep'
require 'codestock/common/dbdir'
include CodeStock

module CodeStock
  class CLI_Cdview
    def self.execute(stdout, arguments=[])
      # オプション
      option = FindGrep::FindGrep::DEFAULT_OPTION
      option.dbFile = db_groonga_path(db_default_dir)
      
      # デフォルトのマッチモードは'File'
      option.isMatchFile = true

      # オプション解析
      opt = OptionParser.new("#{File.basename($0)} [option] keyword1 [keyword2 ...]")
      opt.on('--db [GREN_DB_FILE]', 'Search from the grendb database.') {|v| option.dbFile = db_groonga_path(v) }
      opt.on('-f KEYWORD', '--file-keyword KEYWORD', 'Path keyword. (Enable multiple call)') {|v| option.filePatterns << v}
      opt.on('-s SUFFIX', '--suffix SUFFIX',  'Search suffix.') {|v| option.suffixs << v }
      opt.on('-i', '--ignore', 'Ignore case.') {|v| option.ignoreCase = true}
      opt.on('-c', '--color', 'Color highlight.') {|v| option.colorHighlight = true}
      opt.on('--no-snip', 'There being a long line, it does not snip.') {|v| option.noSnip = true }
      opt.on('-g', '--groonga-only', 'Search only groonga db.') {|v| option.groongaOnly = true }
      opt.on('--mf', '--match-file', 'Match file. (Default)') {|v| option.isMatchFile = true }
      opt.on('-l', '--ml', '--match-line', 'Match line, same mode as "gren".') {|v| option.isMatchFile = false }

      opt.parse!(arguments)

      # 検索オブジェクトの生成
      if (option.dbFile && (arguments.size > 0 || option.keywordsOr.size > 0))
        findGrep = FindGrep::FindGrep.new(arguments, option)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
        stdout.puts
        stdout.puts "please set GREN DATABSE FILE!! (--db option, or set ENV['GRENDB_DEFAULT_DB'].)" unless option.dbFile
      end

    end
  end
end
