###############################################################################
### CMSC330 Project 5: Multi-threaded Metro Simulation                      ###
### Source code: metro.rb                                                   ###
### Description: A multi-threaded Ruby program that simulates               ###
###              the Washington Metro by creating Train and Person threads  ###
###############################################################################

require "monitor"

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

$actions = ["entering", "leaving"]
$colors = ["red", "green", "yellow", "orange", "blue"]

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

# [{:color => "blue", :action => "entering", :station => "Largo Town Center"}]
def parse_train_output(output)
  output.each_with_index.map do |msg, index|
    match_data = msg.match(/^Train ([\w]+) (entering|leaving) ([\D]+)$/)
    {:index => index, :color => match_data[1], :action => match_data[2], :station => match_data[3]} if match_data
  end.compact
end

def parse_person_output(output)
  output.each_with_index.map do |msg, index|
    match_data = msg.match(/^([\w]+) (boarding|leaving) train ([\w]+) at ([\D]+)$/)
    {:index => index, :name => match_data[1], :action => match_data[2], :color => match_data[3], :station => match_data[4]} if match_data
  end.compact
end

def parse_input(input)
  input.inject({}) do |hash, info|
    hash[info[0]] = info[1..-1]
    hash
  end
end

def filter_output_by_train(color, output)
  parse_train_output(output).select{ |hash| hash[:color] == color }
end

def filter_output_by_station(station, output)
  parse_train_output(output).select{ |hash| hash[:station] == station }
end

def filter_output_by_name(name, output)
  parse_person_output(output).select{ |hash| hash[:name] == name }
end

def verify_entering_and_leaving(color, output)
  filtered_output = filter_output_by_train(color, output)

  filtered_output.each_with_index.all? do |hash, index|
    hash[:action] == $actions[index % 2]
  end
end

def verify_all_entering_and_leaving(output)
  $colors.all? { |color| verify_entering_and_leaving(color, output) }
end

def verify_station_order(color, output)
  filtered_output = filter_output_by_train(color, output)
  station_list = stations(color)

  filtered_output.each_with_index.all? do |hash, index|
    hash[:station] == station_list[index / 2 % station_list.length]
  end
end

def verify_all_station_order(output)
  $colors.all? { |color| verify_station_order(color, output) }
end

def stations(color)
  stations = eval("$#{color}_line")
  stations[0..-2] + stations.reverse[0..-2]
end

def verify_no_train_overlap(output)
  stations = parse_train_output(output).map{ |hash| hash[:station] }.uniq
  stations.all? do |station|
    filtered_output = filter_output_by_station(station, output)

    filtered_output.each_with_index.all? do |hash, index|
      hash[:action] == $actions[index % 2]
    end
  end
end

def verify_person_follows_path(name, input, output)
  path = parse_input(input)[name]
  filter_output_by_name(name, output).each_with_index.all? do |hash, index|
    hash[:station] == path[(index + 1) / 2]
  end
end

def verify_all_people_follow_path(input, output)
  names_in_input(input).all? { |name| verify_person_follows_path(name, input, output) }
end

def verify_boarding_and_leaving(output)
  person_output = parse_person_output(output)
  train_output = parse_train_output(output)

  person_output.all? do |person_hash|
    filtered_train_output = filter_output_by_train(person_hash[:color], output)
    train_previous_hash = filtered_train_output.select{ |train_hash| train_hash[:index] < person_hash[:index] }.last
    train_next_hash = filtered_train_output.select{ |train_hash| train_hash[:index] > person_hash[:index] }.first

    (train_previous_hash && train_previous_hash[:action] == "entering") && (train_next_hash.nil? || train_next_hash[:action] == "leaving")
  end
end

def verify_no_extra_people(input, output)
  names_in_output = parse_person_output(output).map{ |hash| hash[:name] }.uniq
  names_in_input(input).sort == names_in_output.sort
end

def verify_no_extra_trains(output)
  colors_in_output = parse_train_output(output).map{ |hash| hash[:color] }.uniq
  colors_in_output.all? { |color| $colors.include? color }
end

def names_in_input(input)
  parse_input(input).keys
end

def verify(input, output)
  verify_all_entering_and_leaving(output) &&
    verify_all_station_order(output) &&
    verify_no_train_overlap(output) &&
    verify_all_people_follow_path(input, output) &&
    verify_boarding_and_leaving(output) &&
    verify_no_extra_people(input, output) &&
    verify_no_extra_trains(output)
end

puts verify($sample_input, $sample_out)