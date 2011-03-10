# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'mkgrendb')

module Mkgrendb
  class CLI
    def self.execute(stdout, arguments=[])
      input_yamls = []
      isDump = false
      isFull = false
      isDelete = false
      isReport = false

      opt = OptionParser.new "#{File.basename($0)} INPUT_YAML1 [INPUT_YAML2 ...]"
      opt.on('--ddb', "--default-db", "Create or Update default DB. (Plase set ENV['GRENDB_DEFAULT_DB'])") {|v| input_yamls << ENV['GRENDB_DEFAULT_DB']}
      opt.on('--full', "Full update DB. (Delete and create)") {|v| isFull = true }
      opt.on('--delete', "Delete DB. (Not delete yaml)") {|v| isDelete = true }
      opt.on('--dump', "Dump DB.") {|v| isDump = true }
      opt.on('--report', "Database Report.") {|v| isReport = true }
      opt.parse!(arguments)

      input_yamls.concat arguments

      if (input_yamls.size >= 1)
        input_yamls.each do |input_yaml|
          obj = Mkgrendb.new(input_yaml)
          
          if (isFull)
            obj.full
            stdout.puts
          elsif (isDelete)
            obj.delete
            stdout.puts
          elsif (isDump)
            obj.dump
          elsif (isReport)
            obj.report
          else
            obj.update
            stdout.puts
          end

        end
      else
        stdout.puts opt.help
      end
    end
  end
end
