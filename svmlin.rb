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

SVMLIN = "~/packages/svmlin-v1.0/svmlin"

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

# liblinear 

LIBLINEAR_DIR = "~/packages/liblinear-1.94"

cmd = "#{LIBLINEAR_DIR}/train #{name}"
system cmd

cmd = "#{LIBLINEAR_DIR}/predict #{name}.t #{name}.model  liblinear.#{name}.out"
system cmd

cmd = "#{LIBLINEAR_DIR}/train -v 10  #{name}.t"
system cmd



#[0.01, 0.05, 0.1].each do |u|
#[0.01, 0.05, 0.1].each do |w|

[0.01].each do |u|
[0.01].each do |w|
  puts "acc -A 2 -W #{w} -U #{u} "
  cmd = "#{SVMLIN} -A 3 -W #{w} -U #{u}  #{svmlin_examples} #{svmlin_labels} > /dev/null"
  system cmd    

  cmd = "#{SVMLIN} -f #{svmlin_examples}.weights #{test_examples} #{test_labels} | grep -i acc"
  system cmd

  puts "acc -A 3 -W #{w} -U #{u} "
  cmd = "#{SVMLIN} -A 3 -W #{w} -U #{u}  #{svmlin_examples} #{svmlin_labels} > /dev/null"
  system cmd

  cmd = "#{SVMLIN} -f #{svmlin_examples}.weights #{test_examples} #{test_labels} | grep -i acc" 
  system cmd

end
end
# TODO: measure how many pos / neg labels in the training data
