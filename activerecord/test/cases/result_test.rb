require "cases/helper"
require 'models/topic'

module ActiveRecord
  class ResultTest < ActiveRecord::TestCase
    fixtures :topics
    def result
      Result.new(['col_1', 'col_2'], [
        ['row 1 col 1', 'row 1 col 2'],
        ['row 2 col 1', 'row 2 col 2'],
        ['row 3 col 1', 'row 3 col 2'],
      ])
    end

    test "length" do
      assert_equal 3, result.length
    end

    test "to_hash returns row_hashes" do
      assert_equal [
        {'col_1' => 'row 1 col 1', 'col_2' => 'row 1 col 2'},
        {'col_1' => 'row 2 col 1', 'col_2' => 'row 2 col 2'},
        {'col_1' => 'row 3 col 1', 'col_2' => 'row 3 col 2'},
      ], result.to_hash
    end

    test "each with block returns row hashes" do
      result.each do |row|
        assert_equal ['col_1', 'col_2'], row.keys
      end
    end

    test "returns first record" do
      #assert_equal( Model.last, last_register, "It's not the lastrecord")
      t = Topic.create!(title: "The first topic", written_on: Time.now, author_name: "The first author")
      u = Topic.create!(title: "The second topic", written_on: Time.now, author_name: "The second author")
      v = Topic.create!(title: "The third topic", written_on: Time.now, author_name: "The third author")
      w = Topic.create!(title: "The last topic", written_on: Time.now, author_name: "The last author")
      assert_equal( t, Topic.first, "It's not the first record")
    end

    test "returns last record" do
      #sospechoso este pasa ammm
      #assert_equal( Model.last, last_register, "It's not the lastrecord")
      t = Topic.create!(title: "The first topic", written_on: Time.now, author_name: "The first author")
      u = Topic.create!(title: "The second topic", written_on: Time.now, author_name: "The second author")
      v = Topic.create!(title: "The third topic", written_on: Time.now, author_name: "The third author")
      w = Topic.create!(title: "The last topic", written_on: Time.now, author_name: "The last author")
      assert_equal( w, Topic.last, "It's not the last record")
    end

    test "each without block returns an enumerator" do
      result.each.with_index do |row, index|
        assert_equal ['col_1', 'col_2'], row.keys
        assert_kind_of Integer, index
      end
    end

    if Enumerator.method_defined? :size
      test "each without block returns a sized enumerator" do
        assert_equal 3, result.each.size
      end
    end

    test "cast_values returns rows after type casting" do
      values = [["1.1", "2.2"], ["3.3", "4.4"]]
      columns = ["col1", "col2"]
      types = { "col1" => Type::Integer.new, "col2" => Type::Float.new }
      result = Result.new(columns, values, types)

      assert_equal [[1, 2.2], [3, 4.4]], result.cast_values
    end

    test "cast_values uses identity type for unknown types" do
      values = [["1.1", "2.2"], ["3.3", "4.4"]]
      columns = ["col1", "col2"]
      types = { "col1" => Type::Integer.new }
      result = Result.new(columns, values, types)

      assert_equal [[1, "2.2"], [3, "4.4"]], result.cast_values
    end

    test "cast_values returns single dimensional array if single column" do
      values = [["1.1"], ["3.3"]]
      columns = ["col1"]
      types = { "col1" => Type::Integer.new }
      result = Result.new(columns, values, types)

      assert_equal [1, 3], result.cast_values
    end

    test "cast_values can receive types to use instead" do
      values = [["1.1", "2.2"], ["3.3", "4.4"]]
      columns = ["col1", "col2"]
      types = { "col1" => Type::Integer.new, "col2" => Type::Float.new }
      result = Result.new(columns, values, types)

      assert_equal [[1.1, 2.2], [3.3, 4.4]], result.cast_values("col1" => Type::Float.new)
    end
  end
end
