#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$LOAD_PATH << File.expand_path(File.join(".."), File.dirname(__FILE__))

require "rubygems"
require "rspec/autorun" 
require "ruby_ga"

describe Population, "when setup" do
  before do
    @unit_num = 30
    @gene_size = 30
    conf = RubyGAConfig.new(
      unit_num = @unit_num,
      gene_size=50,
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
    conf.fitness = method(:sum_items)
    @po = Population.new conf
  end

  it "#units.size should be #{@unit_num}" do
    @po.units.size.should == @unit_num
  end

  after do
    @po = nil
  end
end
