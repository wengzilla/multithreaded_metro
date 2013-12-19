require 'test/unit'
require 'metro.rb'

class MetroTest < Test::Unit::TestCase
  def test_filter_output_by_train
    output = ["Train blue entering Largo Town Center",
      "Train red entering Glen-mont",
      "Train blue leaving Largo Town Center"]
    assert_equal [{:index => 1, :color => "red", :action => "entering", :station => "Glen-mont"}], filter_output_by_train("red", output)
  end

  def test_parse_train_output
    output = ["Train blue entering Largo Town Center",
      "Alice boarding train green at College Park"]
    assert_equal [{:index => 0, :color => "blue", :action => "entering", :station => "Largo Town Center"}], parse_train_output(output)
  end

  def test_parse_person_output
    output = ["Train blue entering Largo Town Center",
      "Alice boarding train red at L'Enfant Plaza"]
    assert_equal [{:index => 1, :name => "Alice", :action => "boarding", :color => "red", :station => "L'Enfant Plaza"}], parse_person_output(output)
  end

  def test_parse_input
    input = [ ["Alice", "College Park", "Gallery Place"] ]
    assert_equal({"Alice" => ["College Park", "Gallery Place"]}, parse_input(input))
  end

  def test_verify_entering_and_leaving
    output = ["Train blue entering Largo Town Center",
      "Train red entering Glenmont",
      "Train blue leaving Largo Town Center"]
    assert_equal true, verify_entering_and_leaving("blue", output)

    output = ["Train blue entering Largo Town Center",
      "Train red entering Glenmont",
      "Train blue entering Stadium-Armory"]
    assert_equal false, verify_entering_and_leaving("blue", output)
  end

  def test_verify_station_order
    output = ["Train blue entering Largo Town Center",
      "Train red entering Glenmont",
      "Train blue leaving Largo Town Center",
      "Train blue entering Stadium-Armory"]
    assert_equal true, verify_station_order("blue", output)

    output = [ "Train blue entering Stadium-Armory"]
    assert_equal false, verify_station_order("blue", output)
  end

  def test_verify_no_train_overlap
    output = ["Train blue entering Stadium-Armory",
      "Train blue leaving Stadium-Armory",
      "Train red entering Stadium-Armory"]
    assert_equal true, verify_no_train_overlap(output)

    output = ["Train blue entering Stadium-Armory",
      "Train red entering Stadium-Armory",
      "Train blue leaving Stadium-Armory"]
    assert_equal false, verify_no_train_overlap(output)
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
    assert_equal true, verify_person_follows_path("Alice", input, output)

    output = ["Alice boarding train red at College Park",
      "Alice leaving train red at Gallery Place"]
    assert_equal false, verify_person_follows_path("Alice", input, output)
  end

  def test_verify_boarding_and_leaving
    output = ["Train green entering College Park",
      "Alice boarding train green at College Park",
      "Train green leaving College Park",
      "Train green entering Fort Totten",
      "Alice leaving train green at Fort Totten",
      "Train green leaving Fort Totten",
      "Train green entering Fort Totten",
      "Alice boarding train green at Fort Totten"]
    assert_equal true, verify_boarding_and_leaving(output)

    output = ["Train green entering Fort Totten",
      "Alice boarding train green at Fort Totten"]
    assert_equal true, verify_boarding_and_leaving(output)

    output = ["Train green entering Fort Totten",
      "Alice boarding train red at Fort Totten"]
    assert_equal false, verify_boarding_and_leaving(output)
  end

  def test_verify_no_extra_people
    input = [ ["Alice", "College Park", "Fort Totten", "Union Station"] ]
    output = ["Train green entering College Park",
      "Alice boarding train green at College Park"]
    assert_equal true, verify_no_extra_people(input, output)

    output = ["Train green entering College Park",
      "Alice boarding train green at College Park",
      "John boarding train red at Fort Totten"]
    assert_equal false, verify_no_extra_people(input, output)
  end

  def test_stations
    assert_equal ["Greenbelt", "College Park", "Fort Totten", "Gallery Place",
                "L'Enfant Plaza", "Branch Ave", "L'Enfant Plaza", "Gallery Place",
                "Fort Totten", "College Park"], stations("green")
  end
end