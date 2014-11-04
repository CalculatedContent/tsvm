#!/usr/bin/env  ruby
require 'trollop'
opts = Trollop::options do
  opt :n, "num L examples", :type => :int, :default => 90
  opt :c, "regularization parameter", :type => :float, :default => 1.0
end


LIBLINEAR="~/packages/liblinear-1.94"

name = opts[:n].to_s
C = opts[:c]

baseline_train = "svmlight.testL."+name
baseline_HO = "svmlight.testHO."+name

baseline_cmd = "#{LIBLINEAR}/train -c #{C} #{baseline_train} ; #{LIBLINEAR}/predict  #{baseline_HO} #{baseline_train}.model out | grep Acc"
puts baseline_cmd
system baseline_cmd

