#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(File.expand_path(__FILE__)) + "/../")

require "ruby_ga"
require "pp"

#def generate_points(pnum=100, xrange=200, yrange=200, uniq=true)
#  points = []
#  pnum.times do |i|
#    points << [rand(xrange) - xrange/2, rand(yrange) - yrange/2]
#  end
#
#  if uniq == true
#    points = points.uniq
#    while(points.size < pnum)
#      points << [rand(xrange) - xrange/2, rand(yrange) - yrange/2]
#    end
#  end
#  return points
#end

#$point_num = 500
#$points = [
#  [0,80],
#  [0,-80],
#  [60,60],
#  [-60,-60],
#  [-60,60],
#  [60,-60],
#  [80,0],
#  [-80,0]
#]
#$points = generate_points($point_num)

# test_simple_gaで使う評価関数
def count_true(ary)
  sum = 0
  ary.each do |a|
    sum += 1 if a == true
  end
  return sum
end

def test_simple_ga(num_try)
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
    desc="simple GA test"
  )

  # Setup directory for gnuplot related files.
  datdir = File.dirname(File.expand_path(__FILE__)) + "/dat/simple_ga"
  if !Dir.exist?(datdir)
    Dir.mkdir(datdir)
  end

  ["roulette", "elite", "tournament", "rank"].each do |sel|
    gpl_cmd = "plot"
    ["inversion", "translocation", "move", "scramble", "else"].each do |mut|
      po = Population.new conf
      fun = method(:count_true)
      file = open("#{datdir}/evo_#{sel}_#{mut}.dat", "w+")
      num_try.times do |i|
        po.simple_ga(fun, sel, mut)
        #po.modified_ga(fun)
        #puts "fit: " + po.elite_selection(fun).fitness(fun).to_s
        file.write("#{i} #{po.average_fitness(fun)}\n")
      end
      file.close
      gpl_cmd += " 'evo_#{sel}_#{mut}.dat' w l,"

      puts "selection=#{sel}, mutation=#{mut}, avg=#{po.average_fitness(fun)}, dev=#{po.deviation_fitness(fun)}"
    end
    gpl_cmd.chop!
    open("#{datdir}/#{sel}.gpl", "w+") {|f| f.write(gpl_cmd)}
  end
end

def main
  num_try = 1000
  test_simple_ga(num_try)
end

main
