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
def distance(p1, p2)
  return ((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)
end

def generate_points(pnum=100, xrange=200, yrange=200)
  points = []
  pnum.times do |i|
    points << [rand(xrange) - xrange/2, rand(yrange) - yrange/2]
  end
  points << points[0].dup
  return points
end

def main
  conf = RubyGAConfig.new
  pp conf
  po = Population.new conf
  fun = method(:count_true)
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

test_simple_ga
#main()
