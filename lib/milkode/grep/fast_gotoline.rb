# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/05/03

require 'milkode/common/util'

module Milkode
  class FastGotoline
    def initialize(gotolines, yaml)
      @gotolines = gotolines
      @yaml      = yaml
    end

    def search_and_print(stdout)
      @gotolines.each do |gotoline|
        package_name, restpath = Util::divide_shortpath(gotoline[0][0])
        package                = @yaml.find_name(package_name)

        if package
          path          = File.join(package.directory, restpath)
          relative_path = Util::relative_path(path, Dir.pwd).to_s
          lineno        = gotoline[1]
          content       = get_text_lineno(path, lineno)

          if content          
            stdout.puts "#{relative_path}:#{lineno} #{content}"
          end
        end
      end
    end

    def get_text_lineno(path, no)
      index = no - 1

      begin
        open(path, "r") do |file|
          file.each_with_index do |line, i|
            return line.chomp if i == index
          end
        end
      rescue Errno::ENOENT
        # ファイルが見つからない時もnilを返す
      end

      nil
    end
    
  end
end

