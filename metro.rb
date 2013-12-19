###############################################################################
### CMSC330 Project 5: Multi-threaded Metro Simulation                      ###
### Source code: metro.rb                                                   ###
### Description: A multi-threaded Ruby program that simulates               ###
###              the Washington Metro by creating Train and Person threads  ###
###############################################################################

require "monitor"
require "verifier.rb"

Thread.abort_on_exception = true   # abort all threads if Exception thrown

$red_line = [ "Glenmont", "Silver Spring", "Fort Totten", "Union Station",
              "Gallery Place", "Metro Center", "Bethesda", "Shady Grove" ]

$green_line = [ "Greenbelt", "College Park", "Fort Totten", "Gallery Place",
                "L'Enfant Plaza", "Branch Ave" ]

$yellow_line = [ "Fort Totten", "Gallery Place", "L'Enfant Plaza", "Pentagon",
                 "Airport", "King Street", "Huntington" ]

$orange_line = [ "New Carrolton", "Stadium-Armory", "Eastern Market", 
                 "L'Enfant Plaza", "Smithsonian", "Metro Center", 
                 "Foggy Bottom", "Rosslyn", "Ballston", "Vienna" ]

$blue_line = [ "Largo Town Center", "Stadium-Armory", "Eastern Market",
               "L'Enfant Plaza", "Smithsonian", "Metro Center", "Foggy Bottom",
               "Rosslyn", "Arlington Cemetery", "Pentagon", "Airport", 
               "King Street", "Franconia-Springfield" ]

$sample_input = [ ["Alice", "College Park", "Gallery Place"] ]

$sample_out = [ "Train green entering Greenbelt", 
    "Train blue entering Largo Town Center", 
    "Train orange entering New Carrolton", 
    "Train yellow entering Fort Totten", 
    "Train red entering Glenmont", 
    "Train blue leaving Largo Town Center", 
    "Train yellow leaving Fort Totten", 
    "Train orange leaving New Carrolton", 
    "Train green leaving Greenbelt", 
    "Train blue entering Stadium-Armory", 
    "Train red leaving Glenmont", 
    "Train yellow entering Gallery Place", 
    "Train green entering College Park", 
    "Alice boarding train green at College Park", 
    "Train red entering Silver Spring", 
    "Train blue leaving Stadium-Armory", 
    "Train orange entering Stadium-Armory" ]

#----------------------------------------------------------------
# Metro Simulator
#----------------------------------------------------------------

def simulate(input)
  puts "Train red entering Glenmont" 
end

# simulate($sample_input)

#----------------------------------------------------------------
# Simulation Verifier
#----------------------------------------------------------------

def verify(input, output)
  Verifier.new(input, output).verify
end

puts verify($sample_input, $sample_out)