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

def main
  conf = RubyGAConfig.new(
    unit_num=32,
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
  po = Population.new conf
  10000.times do |i|
    po.simple_ga(conf.fitness, conf.selection, conf.mutation)
    if i%100 == 0
      puts "avg=#{po.average_fitness(conf.fitness)}, dev=#{po.deviation_fitness(conf.fitness)}"
      puts "total_val=#{po.elite_selection(conf.fitness).fitness(conf.fitness)}"
    end
  end
end

# TPSで使う評価関数
def sum_distances(gene_ary)
  sum = 0.0
  i = 0
  while(i < gene_ary.size - 1)
    dist = distance($points[gene_ary[i]], $points[gene_ary[i+1]])
    #puts "points: #{points[gene_ary[i]]}, #{points[gene_ary[i+1]]}"
    #puts "dist: #{dist}"
    sum += dist
    i += 1
  end
  return 1.0/sum * 10000
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

def test_tsp
  conf = RubyGAConfig.new(
    unit_num=50,
    gene_size=nil,
    gene_var=(0..($point_num-1)).to_a,
    genes=[],
    fitness=nil,
    selection=nil,
    mutation="inversion",
    crossover="cut_from_left",
    #crossover="stitch",
    crossoverProbability=nil,
    mutationProbability=nil,
    desc="TSP test"
  )
  genes = []
  conf.unit_num.times{|i|
    genes << conf.generate_gene(cond="tsp")
  }
  conf.genes = genes
  fun = method(:sum_distances)
  conf.fitness = fun
  po = Population.new conf

  gnuplot_str = "set xrange [-100:100]\nset yrange[-100:100]\n"
  5000.times do |i|
    po.simple_ga(conf.fitness, conf.selection, conf.mutation)
    if i%500 == 0
      puts "avg=#{po.average_fitness(conf.fitness)}, dev=#{po.deviation_fitness(conf.fitness)}"
      #puts "best=#{po.elite_selection(conf.fitness).fitness(conf.fitness)}"
      open("dat/points#{i}.dat", "w+"){|f|
        best_unit = po.elite_selection(conf.fitness)
        #p best_unit.gene
        best_unit.gene.each do |idx|
          point = $points[best_unit.gene[idx]]
          f.write "#{point[0]} #{point[1]}\n"
        end
        f.write "#{$points[best_unit.gene[0]][0]} #{$points[best_unit.gene[0]][1]}\n"  # 元の位置に戻るように最初の点を追加する
      }

      gnuplot_str += 'plot "points' + i.to_s + '.dat" with linespoints' + "\n"
      gnuplot_str += "pause 1\n"
    end
  end
  open("dat/plot.gpl", "w+"){|f| f.write(gnuplot_str)}
end

# test_simple_gaで使う評価関数
def count_true(ary)
  sum = 0
  ary.each do |a|
    sum += 1 if a == true
  end
  return sum
end

def test_simple_ga
  conf = RubyGAConfig.new(
    unit_num=100,
    gene_size=50,
    gene_var=nil,
    genes=nil,
    fitness=nil,
    selection=nil,
    mutation=nil,
    crossover=nil,
    crossoverProbability=nil,
    mutationProbability=nil,
    desc="simple GA(?) test"
  )
  ["roulette", "elite", "tournament", "rank"].each do |sel|
    gpl_cmd = "plot"
    ["inversion", "translocation", "move", "scramble", "else"].each do |mut|
      po = Population.new conf
      fun = method(:count_true)
      file = open("dat/evo_#{sel}_#{mut}.dat", "w+")
      2000.times do |i|
        po.simple_ga(fun, sel, mut)
        #po.modified_ga(fun)
        #puts "fit: " + po.elite_selection(fun).fitness(fun).to_s
        file.write("#{i} #{po.average_fitness(fun)}\n")
      end
      file.close
      gpl_cmd += " 'evo_#{sel}_#{mut}.dat' w l,"

      puts "selection=#{sel}, muration=#{mut}, avg=#{po.average_fitness(fun)}, dev=#{po.deviation_fitness(fun)}"
    end
    gpl_cmd.chop!
    open("dat/#{sel}.gpl", "w+") {|f| f.write(gpl_cmd)}
  end
end

test_simple_ga
#main()
