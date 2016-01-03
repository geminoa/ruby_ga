#!/usr/bin/env ruby
# coding: utf-8

$LOAD_PATH << File.expand_path(File.join(".."), File.dirname(__FILE__))

require "rubygems"
require "ruby_ga"
require "minitest/autorun"

class TestIndividual < Minitest::Test 
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

  def test_gene_size
    assert_equal @ind.gene_size, @gene_size
  end

  def test_duplicated_gene
    assert_equal @ind.gene, @conf.genes[0]
    assert_equal false, (@ind.gene.__id__ == @conf.genes[0].__id__)
  end

  def test_get_older
    cur_age = @ind.age
    @ind.get_older
    assert_equal @ind.age, cur_age + 1
  end
end
