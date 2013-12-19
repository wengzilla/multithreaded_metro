#!/usr/bin/env ruby 

require "metro.rb"
require "utils.rb"

Thread.abort_on_exception = true

empty_list = []

input_array = empty_list.to_a
output_array = empty_list.to_a

puts "verify00: verify() -> true, empty input -> empty output"

begin
  result = verify(input_array, output_array)
rescue Exception => e
  puts e
  puts "FAILED!\n"
  exit(1)
end

if is_true?(result) then
  puts "PASSED!\n"
  exit(0)
else
  puts "FAILED!\n"
  exit(1)
end

