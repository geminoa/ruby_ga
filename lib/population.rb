class Population 
  $defaultUnitNum = 100
  $crossoverProbability = 0.8
  $mutationProbability = 0.05 
  attr_reader :units

  def initialize(unit_num=$defaultUnitNum)
    @units = []
    unit_num.times{|i| @units << Individual.new}
  end

  def go(fun)
    rank = {}  # key: index of @unit, val: fitness.
    @units.size.times do |i|
      rank[i] = @units[i].fitness(fun)
    end
    rank = rank.sort_by{|k,v| v}  # Rearrange based on the fitness.
    rank.reverse!

    # Select parents move to the next generation.
    new_units = []
    orig_units_size = @units.size
    while(new_units.size < orig_units_size)
      #parent1 = roulette_selection!(fun)
      parent1 = rank_selection!(fun)
      parent1.get_older
      #parent2 = roulette_selection!(fun)
      parent2 = rank_selection!(fun)
      parent2.get_older
      if rand(100) < $crossoverProbability*100
        2.times do |i|
          child = parent1.crossover(parent2)
          new_units << child if new_units.size < orig_units_size
        end
      end
      new_units << parent1 if new_units.size < orig_units_size
      new_units << parent2 if new_units.size < orig_units_size
    end

    # Mutation
    new_units.each do |unit|
      if rand(100) < $mutationProbability*100
        unit.mutation
      end
    end
    @units = new_units
  end

  # すべてのunitが総当たり的に交差する
  # If you would remain parents in the population, give double_up = true. 
  def crossover_all(double_up=nil)
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

    if double_up == true 
      @units = old_units + new_units
    else
      @units = new_units
    end
  end

  # Terminate units which age is over the 'limit_age'.
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

  def average_age
    sum = 0.0
    @units.each do |unit|
      sum += unit.age
    end
    return sum / @units.size
  end

  def roulette_selection(fun)
    _roulette_selection(fun, nil)
  end

  def roulette_selection!(fun)
    _roulette_selection(fun, true)
  end

  def elite_selection(fun)
    _elite_selection(fun, nil)
  end

  def elite_selection!(fun)
    _elite_selection(fun, true)
  end

  def rank_selection(fun)
    _rank_selection(fun, nil)
  end

  def rank_selection!(fun)
    _rank_selection(fun, true)
  end

  private
  def _roulette_selection(fun, bang=nil) # methodを引数にとる
    # Calculate sum of all fitness in population.
    sum = 0
    @units.each do |unit|
      sum += unit.fitness(fun)
    end

    # Select an unit 
    border = rand(sum)
    tmp_sum = 0
    @units.size.times do |i|
      tmp_sum += @units[i].fitness(fun)
      if tmp_sum > border
        if bang
          return @units.slice!(i)
        else
          return @units[i]
        end
      end
    end
    puts "sum: #{sum}  tmp_sum: #{tmp_sum}  border: #{border}"
    return nil
  end

  def _elite_selection(fun, bang=nil)
    h = {}
    @units.size.times do |i|
      h[i] = @units[i].fitness(fun)
    end
    max_pos = h.sort_by{|k,v| v}.pop  # 評価関数が最大となるunitの位置
    if bang
      return @units.slice!(max_pos[0])
    else
      return @units[max_pos[0]]
    end
  end

  def _rank_selection(fun, bang=nil)
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
    border = rand(sum)

    # 判定
    tmp_sum = 0
    @units.size.times do |i|
      tmp_sum += ranked_fitnesses[i]
      if tmp_sum > border
        if bang
          return @units.slice!(i)
        else
          return @units[i]
        end
      end
    end
    puts "sum: #{sum}  tmp_sum: #{tmp_sum}  border: #{border}"
    return nil
  end

end
