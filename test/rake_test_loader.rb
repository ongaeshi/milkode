#!/usr/bin/env ruby

# Load the test files from the command line.
require 'rubygems'
require 'groonga'

ARGV.each { |f| load f unless f =~ /^-/  }
