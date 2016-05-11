#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(File.expand_path(__FILE__)) + "/../")

require "ruby_ga"
require "pp"

# Configuration

num_try = 30

$item_set = [
  [2,21], [10,22], [7,28], [2,21], [4,12],
  [9,24], [10,15], [7,2], [8,25], [5,28],  # 10
  [3,4],[10,22],[9,36],[8,2],[8,7],
  [5,40],[7,14],[3,40],[9,33],[7,21],  # 20
  [2,28],[10,22],[7,14],[9,36],[7,28],
  [2,21],[10,18],[4,12],[9,24],[10,15],  # 30
  [4,21],[7,2],[8,25],[5,28],[2,28],
  [3,4],[10,22],[9,36],[7,31],[8,2],  # 40
  [8,7],[5,40],[7,14],[5,4],[7,28],
  [3,40],[9,33],[7,35],[7,21],[9,20]  # 50
]


# ナップサック問題で使う評価関数
def sum_items(gene_ary)
  max_weight = 150 
  penalty = 100
  total_weight = 0
  total_val = 0
  $item_set.size.times do |i|
    if gene_ary[i] == true
      total_weight += $item_set[i][0]
      total_val += $item_set[i][1]
    end
  end
  if total_weight > max_weight
    total_val = penalty
  end
  puts "#{total_weight} #{total_val}"
  return total_val
end


def test_knapsack(num_try, conf)
  po = Population.new conf
  fun = method(:sum_items)
  conf.fitness = fun
  num_try.times do |i|
    po.simple_ga(fun, conf.selection)
  end
end

def main(num_try)
  conf = RubyGAConfig.new(
    unit_num = 10,
    gene_size = 50,
    gene_var = [true, false],
    genes = nil,
    fitness = nil,
    selection = "roulette",
    mutation = "inversion",
    #crossover = "uniform",
    crossover = "stitch",
    #crossover = "one_point",
    #crossover = "multi_point",
    crossoverProbability = 0.7,
    mutationProbability = 0.2,
    desc = "knapsack test"
  )

  test_knapsack(num_try, conf)
  #puts "done"
end

main(num_try)
