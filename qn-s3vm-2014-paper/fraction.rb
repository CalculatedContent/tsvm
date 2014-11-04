#!/usr/bin/env ruby

num_pos, num_neg = 0, 0
soft_labels  = $stdin.readlines.map { |x| x.chomp.to_f }

soft_labels.each do |x|
 if x > 0.0 then 
  num_pos += 1
 else x < 0.0
  num_neg += 1
 end
end

fr = num_pos.to_f / (num_pos+ num_neg).to_f
puts "fraction = #{fr}"
