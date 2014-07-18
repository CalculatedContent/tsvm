#!/usr/bin/env  ruby
require 'fileutils'

# run svmlin on training / test data
# TODO: 
#  run liblinear on the generated files if we skip lines
#  compute class weights and fraction r, add to liblinear and svmlin
#  grid search liblinear
#  run tsvm linear svm and also compare
#  extract Accuracy from svmlin and store in an array
#  only report top N

SVMLIN_DIR = "~/packages/svmlin-v1.0"
LIBLINEAR_DIR = "~/packages/liblinear-1.94"

SVMLIN = "#{SVMLIN_DIR}/svmlin"

name = ARGV.first

train_examples = name+".examples"
train_labels = name+".labels"

test_examples = name+".t.examples"
test_labels = name+".t.labels"

svmlin_examples = "svmlin.#{name}.examples"
svmlin_labels = "svmlin.#{name}.labels"
svmlin_output = "svmlin.#{name}.output"


File.open(train_examples,'w') do |f_train|
File.open(train_labels,'w') do |f_labels|

File.open(name) do |f|
  f.each do |line|
    toks = line.chomp.split(/\s+/,2)
    next unless toks.size > 1
    f_train << toks.last << "\n"
    f_labels << toks.first << "\n"
  end
end

end
end


FileUtils.cp(train_examples,svmlin_examples)
FileUtils.cp(train_labels,svmlin_labels)

File.open(svmlin_examples,'a') do |f_svmlin_examples|
File.open(svmlin_labels,'a') do |f_svmlin_labels|

File.open(test_examples,'w') do |f_test_examples|
File.open(test_labels,'w') do |f_test_labels|
  File.open(name+".t") do |f|
    f.each do |line|
      toks = line.chomp.split(/\s+/,2)
      next unless toks.size > 1
      f_test_examples << toks.last << "\n"
      f_svmlin_examples << toks.last << "\n"

      f_test_labels << toks.first << "\n"
      f_svmlin_labels <<  "0\n"
    end
  end
end
end

end
end

# We should do better than the liblinear (or svmlin) baseline (or lower bound)
#  but we do not expect to do much better than the test upper bound
#   (not quite right, we really want the test reconstruction accuracy)
#

# liblinear baseline, not optimized
$stdout << "liblinear baseline (lower bound):  "
cmd = "#{LIBLINEAR_DIR}/train #{name}"
system cmd

cmd = "#{LIBLINEAR_DIR}/predict #{name}.t #{name}.model  liblinear.#{name}.out"
system cmd

$stdout << "linlinear upper bound:  "
# test upper bound
cmd = "#{LIBLINEAR_DIR}/train  #{name}.t"
system cmd

cmd = "#{LIBLINEAR_DIR}/predict #{name}.t #{name}.t.model  liblinear.t.#{name}.out"
system cmd


# svmlin baseline, not optimized                                                                                                                                                               
$stdout << "svmlin baseline (lower bound):  "
cmd = "#{SVMLIN} -A 1 #{train_examples} #{train_labels}"
system cmd

cmd = "#{SVMLIN} -f #{train_examples}.weights #{test_examples} #{test_labels}"
system cmd




# add in the svmlin non-transductive basline
#cmd = "#{SVMLIN} -A 1 #{name}.t.examples #{name}.t.labels "
#system cmd    


# need a more extensive grid search


w_seq = "seq -w 0.0001 0.0002 0.002"
u_seq = "seq -w 0.001 0.005 0.4"


dir = "A2W{1}U{2}"
dir_cmd = "rm -rf #{dir}; mkdir #{dir}; cd #{dir}"
train_cmd = "#{SVMLIN} -A 2 -W {1} -U {2}  ../#{svmlin_examples} ../#{svmlin_labels} > /dev/null"
eval_cmd = "echo A2W{1}U{2}; #{SVMLIN} -f #{svmlin_examples}.weights ../#{test_examples} ../#{test_labels} | grep -i acc"

parallel_cmd = "parallel '#{dir_cmd}; #{train_cmd};#{eval_cmd}' ::: $(#{w_seq}) ::: $(#{u_seq})"
puts parallel_cmd

system parallel_cmd


