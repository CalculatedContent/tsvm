#!/usr/bin/env  ruby
require 'fileutils'

SVMLIN_DIR = "~/packages/svmlin-v1.0"
LIBLINEAR_DIR = "~/packages/liblinear-1.94"

SVMLIN = "#{SVMLIN_DIR}/svmlin"

name = ARGV.first

train_examples = "svmlin.train.examples."+name
train_labels =  "svmlin.train.labels."+name

testL_examples =  "svmlin.testL.examples."+name
testL_labels = "svmlin.testL.labels."+name

testU_examples =  "svmlin.testU.examples."+name
testU_labels = "svmlin.testU.labels."+name

testHO_examples =  "svmlin.testHO.examples."+name
testHO_labels = "svmlin.testHO.labels."+name

#w_seq = "0.009 0.008 0.007 0.006 0.005 0.004 0.003 0.002 0.001 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.07 0.08 0.09 0.1"
#u_seq = "0.009 0.008 0.007 0.006 0.005 0.004 0.003 0.002 0.001 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.07 0.08 0.09 0.1"


w_seq = "seq -w 0.001 0.001 1.0"
u_seq = "seq -w 0.001 0.001 1.0"

dir = "A2W{1}U{2}"
dir_cmd = "rm -rf #{dir}; mkdir #{dir}; cd #{dir}"
train_cmd = "#{SVMLIN} -A 2 -W {1} -U {2}  -R 0.3  ../#{train_examples} ../#{train_labels} > /dev/null"
evalL_cmd = "echo L test A2W{1}U{2}; #{SVMLIN} -f #{train_examples}.weights ../#{testL_examples} ../#{testL_labels} | grep -i acc"
evalU_cmd = "echo U; #{SVMLIN} -f #{train_examples}.weights ../#{testU_examples} ../#{testU_labels} | grep -i acc"
evalHO_cmd = "echo HO; #{SVMLIN} -f #{train_examples}.weights ../#{testHO_examples} ../#{testHO_labels} | grep -i acc"
cleanup = "cd ..; rm -rf #{dir}"

parallel_cmd = "parallel '#{dir_cmd}; #{train_cmd};#{evalL_cmd};#{evalU_cmd};#{evalHO_cmd};#{cleanup}' ::: $(#{w_seq}) ::: $(#{u_seq})"
puts parallel_cmd

system parallel_cmd




