class Simulator
  attr_accessor :train_threads, :people_threads, :current_stations
  attr_reader :input

  COLORS = ["red", "green", "yellow", "orange", "blue"]
  # COLORS = ["red", "green"]

  def initialize(input)
    @input = input
    @train_threads = []
    @people_threads = []
    @current_stations = {}
  end

  def parsed_input
    input.inject({}) do |hash, info|
      hash[info[0]] = info[1..-1]
      hash
    end
  end

  def run
    # mutex = Mutex.new
    # cv = ConditionVariable.new

    COLORS.each do |c|
      self.train_threads << Thread.new(c) do |color|
        train = Train.new(color)
        while true do
          sleep(0.1)
          # mutex.synchronize do 
            if current_stations.values.include?(train.next_station)
              # puts "The #{color} train can't pull into #{train.next_station}. There's a train at that station!"
              nil
            else
              # cv.wait(mutex)
              current_stations[color] = train.next!
              # cv.signal
            end
          # end
        end
      end
    end

    parsed_input.each do |name, path|
      self.people_threads << Thread.new(name, path) do |name, path|
        person = Person.new(name, path)
        until person.finished? do
          if (current_stations[person.color_needed] == person.current_station) && person.waiting?
            person.board!
          elsif current_stations[person.current_train] == person.current_station
            person.leave!
          end
        end
      end
    end

    people_threads.each {|t| t.join }
  end
end

class Train
  attr_accessor :color, :station_list, :current_index

  COLORS = ["red", "green", "yellow", "orange", "blue"]
  # COLORS = ["red", "green"]

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

  def initialize(color)
    @color = color
    @station_list = stations
    @current_index = 0
    print_action("entering")
  end

  def print_action(action)
    print "Train #{color} #{action} #{current_station}\n"
  end

  def next!
    print_action("leaving")
    self.current_index = next_index
    print_action("entering")
    current_station
  end

  def next_station
    station_list[next_index]
  end

  def current_station
    station_list[current_index]
  end

  def self.find_by_origin_and_destination(origin, destination)
    COLORS.find do |color|
      stations = eval("$#{color}_line")
      stations.include?(origin) && stations.include?(destination)
    end
  end

  def stations
    stations = eval("$#{color}_line")
    stations[0..-2] + stations.reverse[0..-2]
  end

  private

  def next_index
    (current_index + 1) % station_list.length
  end
end

class Person
  attr_accessor :state, :current_index, :current_train
  attr_reader :name, :path

  def initialize(name, path)
    @name = name
    @path = path
    @state = :waiting
    @current_index = 0
  end

  def print_action(action)
    print "#{name} #{action} train #{current_train} at #{current_station}\n"
  end

  def color_needed
    Train.find_by_origin_and_destination(current_station, next_station)
  end

  def board!
    self.current_train = color_needed
    print_action("boarding")
    self.state = :on_train
    self.current_index = next_index
    current_station
  end

  def leave!
    print_action("leaving")
    self.current_train = nil
    self.state = :waiting
    current_station
  end

  def finished?
    current_station == path.last && waiting?
  end

  def waiting?
    state == :waiting
  end

  def next_station
    path[next_index]
  end

  def current_station
    path[current_index]
  end

  private

  def next_index
    current_index + 1
  end
end