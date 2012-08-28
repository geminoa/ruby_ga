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

  def elite_selection(fun)
    h = {}
    @units.size.times do |i|
      h[i] = @units[i].fitness(fun)
    end
    max_pos = h.sort_by{|k,v| v}.pop  # 評価関数が最大となるunitの位置
    return @units.slice!(max_pos[0])
  end

  def rank_selection(fun)
    fitnesses = []
    @units.each do |unit|
      fitnesses << unit.fitness(fun)
    end

    # 適合度をランキングする
    rank = [] # 適合度に低いものほど前に格納
    fitnesses.uniq.sort.each do |fit|
      rank << fit
    end

    # 適合度の値を順位に変換
    ranked_fitnesses = [] # 順位に変換された適合度を格納
    fitnesses.each do |fit|
      ranked_fitnesses << rank.index(fit)
    end

    # 基準値を決める
    sum = 0
    ranked_fitnesses.each{|rfit| sum += rfit}
    border = rand(sum+1)

    # 判定
    tmp_sum = 0
    @units.size.times do |i|
      tmp_sum += ranked_fitnesses[i]
      if tmp_sum >= border
        return @units.slice!(i)
      end
    end
    return nil
  end

end
