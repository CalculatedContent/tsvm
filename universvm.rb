#!/usr/bin/env  ruby
require 'fileutils'

UNIVERSVM_DIR = " ~/packages/universvm1.22"
UNIVERSVM = "universvm"

name = ARGV.first

train_file = "usvm."+name+".train"
test_file = "usvm."+name+".test"

File.open(train_file,'w') do |f_train|
File.open(name) do |f|
  f.each do |line|
    toks = line.chomp.split(/\s+/,2)
    next unless toks.size > 1
    f_train << toks.first.to_i << " " << toks.last << "\n"
  end
end
end


FileUtils.cp(train_file,test_file)

File.open(train_file,'a') do |f_train|
File.open(test_file,'a') do |f_test|
 File.open(name+".t") do |f|
    f.each do |line|
      toks = line.chomp.split(/\s+/,2)
      next unless toks.size > 1
      f_train << "-3 " << toks.last << "\n"
      f_test << toks.first.to_i << " " << toks.last << "\n"
    end
 end
end
end

cmd = "#{UNIVERSVM} -V 2 -o 1 -T #{test_file} #{train_file}"
puts `cmd`



w_seq = "seq -w 0.0001 0.0002 0.002"
u_seq = "seq -w 0.001 0.005 0.4"


#dir = "A2W{1}U{2}"
#dir_cmd = "rm -rf #{dir}; mkdir #{dir}; cd #{dir}"
#train_cmd = "#{UNIVERSVM} -A 2 -W {1} -U {2}  ../#{svmlin_examples} ../#{svmlin_labels} > /dev/null"

#eval_cmd = "echo A2W{1}U{2}; #{UNIVERSVM} -f #{svmlin_examples}.weights ../#{test_examples} ../#{test_labels} | grep -i acc"

#parallel_cmd = "parallel '#{dir_cmd}; #{train_cmd};#{eval_cmd}' ::: $(#{w_seq}) ::: $(#{u_seq})"
#puts parallel_cmd

#system parallel_cmd


