#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$LOAD_PATH << File.expand_path(File.join(".."), File.dirname(__FILE__))

require "rubygems"
require "ruby_ga"

describe Individual do
  before do
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

  describe "When setup" do

    describe "gene_size" do
      it {
        expect(@ind.gene_size).to eq(@gene_size)
      }
    end

    describe "duplicated gene" do
      it {
        expect(@ind.gene).to eq(@conf.genes[0])
        expect(@ind.gene.__id__).not_to eq(@conf.genes[0].__id__)
      }
    end
  end

  describe "get_older" do
    it {
      cur_age = @ind.age
      @ind.get_older
      expect(@ind.age).to eq(cur_age + 1)
    }
  end

  after do
    @po = nil
    @ind = nil
  end
end
