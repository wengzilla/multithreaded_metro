require 'test/unit'
require 'verifier.rb'

class VerifierTest < Test::Unit::TestCase
  def test_filter_output_by_train
    input = []
    output = ["Train blue entering Largo Town Center",
      "Train red entering Glen-mont",
      "Train blue leaving Largo Town Center"]
    assert_equal [{:index => 1, :color => "red", :action => "entering", :station => "Glen-mont"}], Verifier.new(input, output).filter_output_by_train("red")
  end

  def test_parse_train_output
    input = []
    output = ["Train blue entering Largo Town Center",
      "Alice boarding train green at College Park"]
    assert_equal [{:index => 0, :color => "blue", :action => "entering", :station => "Largo Town Center"}], Verifier.new(input, output).parse_train_output
  end

  def test_parse_person_output
    input = []
    output = ["Train blue entering Largo Town Center",
      "Alice boarding train red at L'Enfant Plaza"]
    assert_equal [{:index => 1, :name => "Alice", :action => "boarding", :color => "red", :station => "L'Enfant Plaza"}], Verifier.new(input, output).parse_person_output
  end

  def test_parse_input
    input = [ ["Alice", "College Park", "Gallery Place"] ]
    output = []
    assert_equal({"Alice" => ["College Park", "Gallery Place"]}, Verifier.new(input, output).parse_input)
  end

  def test_verify_entering_and_leaving
    input = []
    output = ["Train blue entering Largo Town Center",
      "Train red entering Glenmont",
      "Train blue leaving Largo Town Center"]
    assert_equal true, Verifier.new(input, output).verify_entering_and_leaving("blue")

    output = ["Train blue entering Largo Town Center",
      "Train red entering Glenmont",
      "Train blue entering Stadium-Armory"]
    assert_equal false, Verifier.new(input, output).verify_entering_and_leaving("blue")
  end

  def test_verify_station_order
    input = []
    output = ["Train blue entering Largo Town Center",
      "Train red entering Glenmont",
      "Train blue leaving Largo Town Center",
      "Train blue entering Stadium-Armory"]
    assert_equal true, Verifier.new(input, output).verify_station_order("blue")

    output = [ "Train blue entering Stadium-Armory"]
    assert_equal false, Verifier.new(input, output).verify_station_order("blue")
  end

  def test_verify_no_train_overlap
    input = []
    output = ["Train blue entering Stadium-Armory",
      "Train blue leaving Stadium-Armory",
      "Train red entering Stadium-Armory"]
    assert_equal true, Verifier.new(input, output).verify_no_train_overlap

    output = ["Train blue entering Stadium-Armory",
      "Train red entering Stadium-Armory",
      "Train blue leaving Stadium-Armory"]
    assert_equal false, Verifier.new(input, output).verify_no_train_overlap
  end

  def test_verify_person_follows_path
    input = [ ["Alice", "College Park", "Fort Totten", "Union Station"] ]
    output = ["Train green entering College Park",
      "Alice boarding train green at College Park",
      "Train green leaving College Park",
      "Train green entering Fort Totten",
      "Alice leaving train green at Fort Totten",
      "Alice boarding train red at Fort Totten",
      "Alice leaving train red at Union Station"]
    assert_equal true, Verifier.new(input, output).verify_person_follows_path("Alice")

    output = ["Alice boarding train red at College Park",
      "Alice leaving train red at Gallery Place"]
    assert_equal false, Verifier.new(input, output).verify_person_follows_path("Alice")
  end

  def test_verify_boarding_and_leaving
    input = []
    output = ["Train green entering College Park",
      "Alice boarding train green at College Park",
      "Train green leaving College Park",
      "Train green entering Fort Totten",
      "Alice leaving train green at Fort Totten",
      "Train green leaving Fort Totten",
      "Train green entering Fort Totten",
      "Alice boarding train green at Fort Totten"]
    assert_equal true, Verifier.new(input, output).verify_boarding_and_leaving

    output = ["Train green entering Fort Totten",
      "Alice boarding train green at Fort Totten"]
    assert_equal true, Verifier.new(input, output).verify_boarding_and_leaving

    output = ["Train green entering Fort Totten",
      "Alice boarding train red at Fort Totten"]
    assert_equal false, Verifier.new(input, output).verify_boarding_and_leaving
  end

  def test_verify_no_extra_people
    input = [ ["Alice", "College Park", "Fort Totten", "Union Station"] ]
    output = ["Train green entering College Park",
      "Alice boarding train green at College Park"]
    assert_equal true, Verifier.new(input, output).verify_no_extra_people

    output = ["Train green entering College Park",
      "Alice boarding train green at College Park",
      "John boarding train red at Fort Totten"]
    assert_equal false, Verifier.new(input, output).verify_no_extra_people
  end

  def test_stations
    input = []
    output = []
    assert_equal ["Greenbelt", "College Park", "Fort Totten", "Gallery Place",
                "L'Enfant Plaza", "Branch Ave", "L'Enfant Plaza", "Gallery Place",
                "Fort Totten", "College Park"], Verifier.new(input, output).stations("green")
  end
end