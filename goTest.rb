#!/usr/bin/ruby -w

tests = [ 	"public_verify00.rb", "public_verify01.rb", 
		"public_verify02.rb", "public_verify03.rb", 
		"public_simulate00.rb", "public_simulate01.rb" ]

tests.each { |x|
	puts "------------------"
	puts "Testing #{x}"
	puts "------------------"
	system("#{x}")
}
