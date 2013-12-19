#!/usr/bin/env ruby

def is_true?(result)
  if result == nil || result == false then
    return false
  else
    return true
  end
end

def is_false?(result)
  return !is_true?(result)
end

def read_output(file)
begin
  f = File.open(file)
rescue Exception => e
  puts e
  exit(1)
end
  output_array = []
  f.each_line{|line|
    line.chomp!
    output_array.push(line)
  }
  return output_array
end

