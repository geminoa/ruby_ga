#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "ruby_ga"
require "pp"

# ナップサック問題で使う評価関数
def sum_items(gene_ary)
  max_weight = 80 
  penalty = 100
  item_set = [
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
  total_weight = 0
  total_val = 0
  item_set.size.times do |i|
    if gene_ary[i] == true
      total_weight += item_set[i][0]
      total_val += item_set[i][1]
    end
  end
  #puts "w: #{total_weight}"; puts "v: #{total_val}"
  if total_weight > max_weight
    total_val = penalty
  end
  return total_val
end

def distance(p1, p2)
  if p1.size != p2.size
    raise "dimension of the points is not same!"
  end
  sum = 0.0
  p1.size.times do |i|
    sum += (p1[i] - p2[i])**2
  end
  return Math::sqrt(sum)
end

def generate_points(pnum=100, xrange=200, yrange=200, uniq=true)
  points = []
  pnum.times do |i|
    points << [rand(xrange) - xrange/2, rand(yrange) - yrange/2]
  end

  if uniq == true
    points = points.uniq
    while(points.size < pnum)
      points << [rand(xrange) - xrange/2, rand(yrange) - yrange/2]
    end
  end
  return points
end

$point_num = 500
$points = [
  [0,80],
  [0,-80],
  [60,60],
  [-60,-60],
  [-60,60],
  [60,-60],
  [80,0],
  [-80,0]
]
$points = generate_points($point_num)
