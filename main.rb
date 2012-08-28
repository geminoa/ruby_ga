require "ruby_ga"

def count_true(ary)
  sum = 0
  ary.each do |a|
    sum += 1 if a == true
  end
  return sum
end

def main
	po = Population.new 5
	4.times do
		po.crossover_all(true)
	end
	p po.units.size
  ary = []
  po.units.each do |unit|
     ary << unit.age
  end
  p ary.uniq
  p po.average_age

  units = []
  units << po.roulette_selection(method(:count_true))
  units << po.elite_selection(method(:count_true))
  units << po.rank_selection(method(:count_true))
  units.each{|unit| p unit.fitness(method(:count_true))} 
end

main()
