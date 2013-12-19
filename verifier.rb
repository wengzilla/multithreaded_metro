class Verifier
  attr_reader :input, :output

  ACTIONS = ["entering", "leaving"]
  COLORS = ["red", "green", "yellow", "orange", "blue"]
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

  def initialize(input, output)
    @input = input
    @output = output
  end

  def verify
    puts "#{verify_all_entering_and_leaving} &&
      #{verify_all_station_order} &&
      #{verify_no_train_overlap} &&
      #{verify_all_people_follow_path} &&
      #{verify_boarding_and_leaving} &&
      #{verify_no_extra_people} &&
      #{verify_no_extra_trains}"

    verify_all_entering_and_leaving &&
      verify_all_station_order &&
      verify_no_train_overlap &&
      verify_all_people_follow_path &&
      verify_boarding_and_leaving &&
      verify_no_extra_people &&
      verify_no_extra_trains
  end

  # [{:color => "blue", :action => "entering", :station => "Largo Town Center"}]
  def parse_train_output
    output.each_with_index.map do |msg, index|
      match_data = msg.match(/^Train ([\w]+) (entering|leaving) ([\D]+)$/)
      {:index => index, :color => match_data[1], :action => match_data[2], :station => match_data[3]} if match_data
    end.compact
  end

  def parse_person_output
    output.each_with_index.map do |msg, index|
      match_data = msg.match(/^([\w]+) (boarding|leaving) train ([\w]+) at ([\D]+)$/)
      {:index => index, :name => match_data[1], :action => match_data[2], :color => match_data[3], :station => match_data[4]} if match_data
    end.compact
  end

  def parse_input
    input.inject({}) do |hash, info|
      hash[info[0]] = info[1..-1]
      hash
    end
  end

  def filter_output_by_train(color)
    parse_train_output.select{ |hash| hash[:color] == color }
  end

  def filter_output_by_station(station)
    parse_train_output.select{ |hash| hash[:station] == station }
  end

  def filter_output_by_name(name)
    parse_person_output.select{ |hash| hash[:name] == name }
  end

  def verify_entering_and_leaving(color)
    filtered_output = filter_output_by_train(color)

    filtered_output.each_with_index.all? do |hash, index|
      hash[:action] == ACTIONS[index % 2]
    end
  end

  def verify_all_entering_and_leaving
    COLORS.all? { |color| verify_entering_and_leaving(color) }
  end

  def verify_station_order(color)
    filtered_output = filter_output_by_train(color)
    station_list = stations(color)

    filtered_output.each_with_index.all? do |hash, index|
      hash[:station] == station_list[index / 2 % station_list.length]
    end
  end

  def verify_all_station_order
    COLORS.all? { |color| verify_station_order(color) }
  end

  def stations(color)
    stations = eval("$#{color}_line")
    stations[0..-2] + stations.reverse[0..-2]
  end

  def verify_no_train_overlap
    stations = parse_train_output.map{ |hash| hash[:station] }.uniq
    stations.all? do |station|
      filtered_output = filter_output_by_station(station)

      result = filtered_output.each_with_index.all? do |hash, index|
        hash[:action] == ACTIONS[index % 2]
      end

      puts filtered_output if !result

      result
    end
  end

  def verify_person_follows_path(name)
    path = parse_input[name]
    filter_output_by_name(name).each_with_index.all? do |hash, index|
      hash[:station] == path[(index + 1) / 2]
    end
  end

  def verify_all_people_follow_path
    names_in_input.all? { |name| verify_person_follows_path(name) }
  end

  def verify_boarding_and_leaving
    person_output = parse_person_output
    train_output = parse_train_output

    person_output.all? do |person_hash|
      filtered_train_output = filter_output_by_train(person_hash[:color])
      train_previous_hash = filtered_train_output.select{ |train_hash| train_hash[:index] < person_hash[:index] }.last
      train_next_hash = filtered_train_output.select{ |train_hash| train_hash[:index] > person_hash[:index] }.first

      (train_previous_hash && train_previous_hash[:action] == "entering") && (train_next_hash.nil? || train_next_hash[:action] == "leaving")
    end
  end

  def verify_no_extra_people
    names_in_output = parse_person_output.map{ |hash| hash[:name] }.uniq
    names_in_input.sort == names_in_output.sort
  end

  def verify_no_extra_trains
    colors_in_output = parse_train_output.map{ |hash| hash[:color] }.uniq
    colors_in_output.all? { |color| COLORS.include? color }
  end

  def names_in_input
    parse_input.keys
  end
end
