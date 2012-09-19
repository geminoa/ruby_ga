require "ruby_ga"
require "pp"

# test_simple_gaで使う評価関数
def count_true(ary)
  sum = 0
  ary.each do |a|
    sum += 1 if a == true
  end
  return sum
end

# TPSで使う評価関数
def sum_distances(ary)
  sum = 0.0
  i = 0
  while(i < ary.size - 1)
    sum += distance(ary[i], ary[i+1])
    i += 1
  end
  return 1.0/sum + 100
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

def main
  points = generate_points
  conf = RubyGAConfig.new(unit_num=nil, gene_size=nil, gene_var=(0..99).to_a, genes=[])
  genes = []
  conf.unit_num.times{|i|
    genes << conf.generate_gene(cond="tsp")
  }
  conf.genes = genes
  fun = method(:sum_distances)
  conf.fitness = fun
  po = Population.new conf

  100.times do |i|
    po.simple_ga(conf.fitness, conf.selection, conf.mutation)
    puts "avg=#{po.average_fitness(conf.fitness)}, dev=#{po.deviation_fitness(conf.fitness)}"
  end
end

def test_simple_ga
  conf = RubyGAConfig.new(100, 50)
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

#test_simple_ga
main()
