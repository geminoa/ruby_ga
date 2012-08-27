class Population 
  $defaultUnitNum = 100
  attr_reader :units

  def initialize(unit_num=$defaultUnitNum)
    @units = []
    unit_num.times{|i| @units << Individual.new(nil)}
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

  #private
  def roulette_selection(fun) # methodを引数にとる
    # Calculate sum of all fitness in population.
    sum = 0
    @units.each do |unit|
      sum += unit.fitness(fun)
    end

    # Select an unit 
    border = rand(sum+1)
    tmp_sum = 0
    @units.size.times do |i|
      tmp_sum += units[i].fitness(fun)
      if tmp_sum > border
        return @units.slice!(i)
      end
    end
    return nil
  end

  def elite_selection()

  end

end
