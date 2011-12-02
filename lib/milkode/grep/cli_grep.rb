# -*- coding: utf-8 -*-

require 'optparse'

module Milkode
  class CLI_Grep
    def self.execute(stdout, arguments=[])
      optvalue = Hash.new
      
      opt = OptionParser.new "#{File.basename($0)} [option] pattern"
      opt.on('-p', '--package-root', 'Search package root.') {|v| optvalue[:package_root] = true }
      opt.order!(arguments)

      if (arguments.size > 0)
        p "Main #{optvalue.to_a.join(',')} #{arguments.join(" ")}"
      else
        stdout.print opt.help
      end
    end
  end
end
