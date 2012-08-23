require "individual.rb"

class Population 
	$defaultUnitNum = 100
	attr_reader :units

	def initialize(unit_num=$defaultUnitNum)
		@units = []
		unit_num.times{|i| @units << Individual.new}
	end

	def crossover_all
		tmp_units = @units.dup
		unit = tmp_units.shift

		old_units = []
		new_units = []
		while(tmp_units.size > 0)
			tmp_units.each do |tu|
				new_units << unit.crossover(tu)
			end
			unit.get_older
			old_units << unit
			unit = tmp_units.shift

			if tmp_units.size == 0
				unit.get_older 
				old_units << unit
			end
		end
		@units = old_units + new_units
	end

	def terminate_by_age(limit_age=5)
		tmp_units = []
		@units.each do |un|
			if un.age < limit_age
				tmp_units << un
			end
		end
		@units = tmp_units
		return nil
	end

	def terminate_random(num)
		num.times do
			@units.slice!(rand(@units.size))
		end
	end

end
