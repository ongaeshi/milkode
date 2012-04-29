require 'thor'

module Milkode
  class CLI < Thor
    desc "add PATH", "Add package(s) to milkode"
    option :ignore, :aliases => '-i'
    option :no_auto_ignore, :type => :boolean
    option :verbose, :type => :boolean
    def add(*args)
      p options
      p options[:ignore]
    end
  end
end
