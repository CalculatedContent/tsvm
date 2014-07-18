#!/usr/bin/env ruby

input = ARGV.first
num = ARGV[2] || 1000
name = "#{input}.#{num}"

train_file = name
test_file = "#{name}.t"

#
# select N random instances as train data
#  a bit of a memory hog, sorry
# 
File.open(input) do |f|
  lines = f.readlines
  train_lines = lines.sample(num)
  test_lines = lines - train_lines

  File.open(train_file,'w') { |out| out << train_lines.join("") }
  File.open(test_file,'w') { |out| out << test_lines.join("") }

end


