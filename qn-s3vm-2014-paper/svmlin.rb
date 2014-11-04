#!/usr/bin/env  ruby
require 'fileutils'
require 'trollop'

SVMLIN_DIR = "~/packages/svmlin-v1.0"
LIBLINEAR_DIR = "~/packages/liblinear-1.94"

SVMLIN = "#{SVMLIN_DIR}/svmlin"


opts = Trollop::options do
  opt :l, "num L examples", :type => :int, :default => 90
  opt :a, "A = 2 or 3", :default => 2
  opt :r, "r", :default => 0.31
end

name = opts[:l].to_s
A = opts[:a].to_s
R = opts[:r].to_s


train_examples = "svmlin.train.examples."+name
train_labels =  "svmlin.train.labels."+name

testL_examples =  "svmlin.testL.examples."+name
testL_labels = "svmlin.testL.labels."+name

testU_examples =  "svmlin.testU.examples."+name
testU_labels = "svmlin.testU.labels."+name

testHO_examples =  "svmlin.testHO.examples."+name
testHO_labels = "svmlin.testHO.labels."+name


testB_examples =  "svmlin.testB.examples."+name
testB_labels = "random_labels.90.001"


w_seq = "0.0001 0.001  0.01 0.1 1 10 100 1000 10000 100000"
u_seq = "0.00001 0.0001 0.001 0.01 0.1 1 10 100 1000 10000 100000"

r_seq = "0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37"
#u_seq = "$(seq -w 100 100 5000)"
#w_seq = "$(seq -w 0.0001 0.0001 0.001)"


dir = "A#{A}W{1}U{2}R{3}"
dir_cmd = "rm -rf #{dir}; mkdir #{dir}; cd #{dir}"
train_cmd = "#{SVMLIN} -A #{A} -W {1} -U {2}  -R {3}  ../#{train_examples} ../#{train_labels} | grep Objective "
evalL_cmd = "echo A#{A} W{1} U{2} R#{3}; #{SVMLIN} -f #{train_examples}.weights ../#{testL_examples} ../#{testL_labels} | grep -i acc "
evalU_cmd = "#{SVMLIN} -f #{train_examples}.weights ../#{testU_examples} ../#{testU_labels} | grep -i acc  "
evalHO_cmd = "#{SVMLIN} -f #{train_examples}.weights ../#{testHO_examples} ../#{testHO_labels}  |  grep -i acc  "
evalFR_cmd =" cat #{train_examples}.outputs | ../entropy.rb "
evalS_cmd =" cat #{train_examples}.outputs | ../fraction.rb "

evalMargin = "cat #{train_examples}.outputs | ../margin.rb "

#evalMargin = "cat #{train_examples}.outputs |../hard_labels.rb > labels; #{SVMLIN} ../#{train_examples} labels | grep xxx; #{SVMLIN} -f #{train_examples}.weights ../#{train_examples} labels | grep -i acc ; cat #{train_examples}.weights | ../margin.rb "

cleanup = "cd .."
#cleanup = "cd ..; rm -rf #{dir}"

parallel_cmd = "parallel '#{dir_cmd}; #{train_cmd};#{evalL_cmd};#{evalU_cmd};#{evalHO_cmd};#{evalFR_cmd};#{evalS_cmd};#{evalMargin};#{cleanup}' ::: #{w_seq} ::: #{u_seq} ::: #{r_seq}" 

puts parallel_cmd

system parallel_cmd




