require 'minitest/autorun'
require './find_store'

class FindStoreTest < MiniTest::Unit::TestCase

  def test_haversine_distance
    assert_equal 3.1163345432288434, haversine_distance([35.740100, -78.654500], [35.715270, -78.638490])
  end

end