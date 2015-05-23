#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

load "ruby_ga.rb"
require "rubygems"
require "pp"
#require "parallel"

$:.unshift(File.dirname(File.expand_path(__FILE__)))

$datdir = File.dirname(File.expand_path(__FILE__)) + "/dat"
if !Dir.exist?($datdir)
  Dir.mkdir($datdir)
end
  
# TPSで使う評価関数
def sum_distances(gene_ary)
  sum = 0.0
  i = 0
  while(i < gene_ary.size - 1)
    dist = distance($points[gene_ary[i]], $points[gene_ary[i+1]])
    #puts "points: #{$points[gene_ary[i]]}, #{$points[gene_ary[i+1]]}"
    #puts "dist: #{dist}"
    sum += dist
    i += 1
  end
  puts sum

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

def generate_points(pnum=20, xrange=50, yrange=50, uniq=true)
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

$point_num = 15
$points = generate_points($point_num)

def test_tsp
  conf = RubyGAConfig.new(
    unit_num=50,
    gene_size=nil,
    gene_var=(0..($point_num-1)).to_a,
    genes=[],
    fitness=nil,
    selection="roulette",
    mutation="inversion",
    crossover="cut_from_left",
    #crossover="stitch",
    crossoverProbability=0.7,
    mutationProbability=0.3,
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
  80000.times do |i|
    po.simple_ga(conf.fitness, conf.selection, conf.mutation)
    if i%10000 == 0
      puts "avg=#{po.average_fitness(conf.fitness)}, dev=#{po.deviation_fitness(conf.fitness)}"
      #puts "best=#{po.elite_selection(conf.fitness).fitness(conf.fitness)}"
      open("#{$datdir}/points#{i}.dat", "w+"){|f|
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
  open("#{$datdir}/plot.gpl", "w+"){|f| f.write(gnuplot_str)}
end

test_tsp()
