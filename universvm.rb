#!/usr/bin/env  ruby
require 'fileutils'

UNIVERSVM = " ~/packages/universvm1.22/universvm"

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


c_seq = "0.001 0.001 0.1 1.0 10 100 1000"

train_cmd = "#{UNIVERSVM}  -c {1} -C {2} -o 1 -T #{test_file} #{train_file} > usvm.C{1}.c{2}.out"

parallel_cmd = "parallel  '#{train_cmd}' ::: #{c_seq} ::: #{c_seq}"
puts parallel_cmd

system parallel_cmd


