require "ruby_ga"
require "pp"

def count_true(ary)
  sum = 0
  ary.each do |a|
    sum += 1 if a == true
  end
  return sum
end

def main
  ["roulette", "elite", "rank"].each do |sel|
    ["inversion", "translocation", "move", "scramble", "else"].each do |mut|
      po = Population.new 50
      p po.average_fitness(method(:count_true))
      file = open("dat/evo_#{sel}_#{mut}.dat", "w+")
      500.times do |i|
        po.simple_ga(method(:count_true), sel, mut)
        #po.modified_ga(method(:count_true))
        #puts "fit: " + po.elite_selection(method(:count_true)).fitness(method(:count_true)).to_s
        file.write("#{i} #{po.average_fitness(method(:count_true))}\n")
      end
      file.close
    end
  end
end

main()
