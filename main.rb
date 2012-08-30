require "ruby_ga"

def count_true(ary)
  sum = 0
  ary.each do |a|
    sum += 1 if a == true
  end
  return sum
end

def main
	po = Population.new 50
	200.times do
		po.go(method(:count_true))
    puts "fit: " + po.elite_selection(method(:count_true)).fitness(method(:count_true)).to_s
	end

  ary = []
  po.units.each do |unit|
     ary << unit.age
  end
  p ary.uniq
  p po.average_age
end

main()
