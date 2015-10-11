#!/usr/bin/env ruby
# coding: utf-8

$LOAD_PATH << File.expand_path(File.join(".."), File.dirname(__FILE__))

require "minitest/unit"
require "minitest/autorun"
require "rubygems"
require "ruby_ga"

class TestPopulation < MiniTest::Unit::TestCase
  def setup
    @unit_num = 30
    @gene_size = 30
    @conf = RubyGAConfig.new(
      unit_num = @unit_num,
      gene_size = @gene_size,
      gene_var=nil,
      genes=nil,
      fitness=nil,
      selection="tournament",
      mutation="inversion",
      crossover="uniform",
      crossoverProbability=nil,
      mutationProbability=nil,
      desc="knapsack test"
    )

    @po = Population.new @conf
    @ind = Individual.new(
      @conf.gene_size,
      @conf.gene_var,
      @conf.genes[0], 
      @conf.mutationProbability
    )
  end

  def test_unit_size
    assert_equal @po.units.size, @unit_num
  end
end
