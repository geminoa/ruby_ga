require "population"

def main
	po = Population.new 5
	3.times do
		po.crossover_all
	end

	p po.units
	puts "done"
end

main()
