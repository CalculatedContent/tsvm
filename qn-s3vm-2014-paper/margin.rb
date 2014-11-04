#!/usr/bin/env ruby

norm = 0.0
weights  = $stdin.readlines.map { |x| x.chomp.to_f }
weights.each do |x|
 norm += x*x
end

margin = 1/(norm+0.0001)
puts "margin_2 = #{margin}"
