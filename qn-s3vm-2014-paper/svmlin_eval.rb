#!/usr/bin/env  ruby
require 'fileutils'

require 'trollop'
opts = Trollop::options do
  opt :n, "num L examples", :type => :int, :default => 90
  opt :w, "w", :default => 0.0001
  opt :u, "u", :default => 10.0
end

puts opts

SVMLIN_DIR = "~/packages/svmlin-v1.0"
SVMLIN = "#{SVMLIN_DIR}/svmlin"

name = opts[:n].to_s
w = opts[:w]
u = opts[:u]

train_examples = "svmlin.train.examples."+name
train_labels =  "svmlin.train.labels."+name

testL_examples =  "svmlin.testL.examples."+name
testL_labels = "svmlin.testL.labels."+name

testU_examples =  "svmlin.testU.examples."+name
testU_labels = "svmlin.testU.labels."+name

testHO_examples =  "svmlin.testHO.examples."+name
testHO_labels = "svmlin.testHO.labels."+name

train_cmd = "#{SVMLIN} -A 2 -W #{w} -U #{u}  -R 0.3  #{train_examples} #{train_labels} > /dev/null"
evalL_cmd = "#{SVMLIN} -f #{train_examples}.weights #{testL_examples} #{testL_labels} | grep -i acc | sed -e 's/A/L A/' "
evalU_cmd = "#{SVMLIN} -f #{train_examples}.weights #{testU_examples} #{testU_labels} | grep -i acc  | sed -e 's/A/U A/' "
evalHO_cmd = "#{SVMLIN} -f #{train_examples}.weights #{testHO_examples} #{testHO_labels} | grep -i acc  | sed -e 's/A/HO A/' "

# margin
evalMRGN_cmd ="cat #{train_examples}.weights |  py --ji -l \"numpy.sqrt(numpy.mean(numpy.square(l)))\" | sed -e 's/^/margin: /' "

# entropy  # not working
#evalS_cmd =  "cat #{testU_examples}.outputs | py --ji -l \"numpy.sum(numpy.log(l)*l)\" | sed -e 's/^/entropy U: /' "

cmd  = "#{train_cmd};#{evalL_cmd};#{evalU_cmd};#{evalHO_cmd}"
system cmd
#system evalS_cmd
system evalMRGN_cmd

