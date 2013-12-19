#!/usr/bin/env ruby 

require "metro.rb"
require "utils.rb"

Thread.abort_on_exception = true

input_array = [ ["John", "Fort Totten", "Gallery Place"] ]

output_array = read_output("public_verify01.in")

puts "verify01: verify() -> true, for successful simulation"

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

