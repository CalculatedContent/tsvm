#!/usr/bin/env ruby

s = 0.0
soft_labels  = $stdin.readlines.map { |x| x.chomp.to_f }
soft_labels.map! { |x| 1.0 / (1.0 + Math.exp(-x)) }

pnorm = soft_labels.inject(0.0) { |s,x| s+= x }

soft_labels.map! { |x| x / pnorm }

soft_labels.each do |x|
 s+= x*Math.log10(x) + (1-x)*Math.log(1-x)  
end

puts "entropy = #{s}"
