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
	2.times do
		po.crossover_all
	end

	#p po.units

  units = []
  units << po.roulette_selection(method(:count_true))
  units << po.elite_selection(method(:count_true))
  units << po.rank_selection(method(:count_true))
  units.each{|unit| p unit.fitness(method(:count_true))} 
end

main()
