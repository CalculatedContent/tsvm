#!/usr/bin/ruby

lines = $stdin.readlines

lines.each do |l|
#  if l =~ /A[2|3]/ 
 #   $stdout << l
  toks = l.chomp.split

  if l =~ /Obj/ then
   $stdout << "\n"
   $stdout << toks[3] << "\t"
  elsif l =~ /A[2|3]/
   $stdout << toks.join("\t") << "\t"
  elsif l =~ /Acc/ or l =~ /fraction/ or l=~ /entropy/ or l =~ /margin/ then
   $stdout << toks[2] << "\t"
  else 
   $stdout << l 
  end    

end
