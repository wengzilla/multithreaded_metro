#!/usr/bin/env ruby 

require "metro.rb"
require "utils.rb"

Thread.abort_on_exception = true

input_array = [ ["Paul", "Pentagon", "Hungtington"] ]

output_array = read_output("public_verify03.in")

puts "verify03: verify() -> false, train red leaving before entering Gallery Place"

begin
  result = verify(input_array, output_array)
rescue Exception => e
  puts e
  puts "FAILED!\n"
  exit(1)
end

if is_false?(result) then
  puts "PASSED!\n"
  exit(0)
else
  puts "FAILED!\n"
  exit(1)
end

