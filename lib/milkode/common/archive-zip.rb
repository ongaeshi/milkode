# -*- coding: utf-8 -*-
#
# @file 
# @brief  archive-zipがRuby1.9.2に対応するまでのパッチ
# @author ongaeshi
# @date   2011/08/04

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../../../vendor')
require 'archive/zip'
