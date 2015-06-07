class Population 
  # TODO: to give tournamentSize as the member of RubyGAConfig.
  $tournamentSize = 4

  attr_reader :units
  def initialize(rbga_conf=nil)
    if rbga_conf.class != RubyGAConfig
      raise 'Invalid config. Class of config must be RubyGAConfig.'
    end

    @crossover = rbga_conf.crossover
    @crossoverProbability = rbga_conf.crossoverProbability
    @mutationProbability = rbga_conf.mutationProbability
    @tournamentSize = $tournamentSize
    @units = []
    rbga_conf.unit_num.times do |i|
      @units << Individual.new(rbga_conf.gene_size, rbga_conf.gene_var, rbga_conf.genes[i], @mutationProbability)
    end
  end

  # Evolve population with simple GA.
  # @params fun [Method] evaluation function.
  # @params selection [String] selection method.
  # @params mutation_method [String] mutation method for Individual#mutation.
  def simple_ga(fun, selection=nil, mutation_method=nil)
    # Crossover
    new_units = []
    #if rand(100) > @crossoverProbability*100
    while (new_units.size < @units.size)
      #@units.each{|unit| unit.get_older}
      case selection
      when "roulette"
        parent1 = roulette_selection!(fun)
        parent2 = roulette_selection!(fun)
      when "elite"
        parent1 = elite_selection!(fun)
        parent2 = elite_selection!(fun)
      when "tournament"
        parent1 = tournament_selection!(fun)
        parent2 = tournament_selection!(fun)
      when "rank" 
        parent1 = rank_selection!(fun)
        parent2 = rank_selection!(fun)
      else
        raise "selection method is invalid!"
      end
      child1, child2 = parent1.crossover(parent2, @crossover)
      #@units << parent1 << parent2 << child1 << child2 
      new_units << child1 << child2
      #2.times do
      #  worst = drop_worst_unit(fun)
      #end
    end
    
    # Mutation
    #@units.each do |unit|
    new_units.each do |unit|
      if rand(100) < @mutationProbability*100
        unit.mutation(@mutationProbability, mutation_method)
      end
    end
    @units = new_units
  end

  def simple_ga_old(fun, selection=nil, mutation_method=nil)
    # Crossover
    if rand(100) > @crossoverProbability*100
      @units.each{|unit| unit.get_older}
      case selection
      when "roulette"
        parent1 = roulette_selection!(fun)
        parent2 = roulette_selection!(fun)
      when "elite"
        parent1 = elite_selection!(fun)
        parent2 = elite_selection!(fun)
      when "tournament"
        parent1 = tournament_selection!(fun)
        parent2 = tournament_selection!(fun)
      when "rank" 
        parent1 = rank_selection!(fun)
        parent2 = rank_selection!(fun)
      else
        raise "selection method is invalid!"
      end
      child1, child2 = parent1.crossover(parent2, @crossover)
      @units << parent1 << parent2 << child1 << child2 
      2.times do
        worst = drop_worst_unit(fun)
      end
    end
    
    # Mutation
    @units.each do |unit|
      if rand(100) < @mutationProbability*100
        unit.mutation(@mutationProbability, mutation_method)
      end
    end
  end

  # Experimental
  def modified_ga(fun)
    rank = {}  # key: index of @unit, val: fitness.
    @units.size.times do |i|
      @units[i].get_older
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
      #parent2 = roulette_selection!(fun)
      parent2 = rank_selection!(fun)
      if rand(100) < @crossoverProbability*100
        child1, child2 = parent1.crossover(parent2)
        new_units << child1 if new_units.size < orig_units_size
        new_units << child2 if new_units.size < orig_units_size
      end
      new_units << parent1 if new_units.size < orig_units_size
      new_units << parent2 if new_units.size < orig_units_size
    end

    # Mutation
    new_units.each do |unit|
      if rand(100) < @mutationProbability*100
        unit.mutation
      end
    end
    @units = new_units
  end

  # Add individual into the @units.
  def add(individual)
    if individual.class == Individual
      @units << individual
    end
  end

  def average_age
    sum = 0.0
    @units.each do |unit|
      sum += unit.age
    end
    return sum / @units.size
  end

  def average_fitness(fun)
    sum = 0.0
    @units.each do |unit|
      sum += unit.fitness(fun)
    end
    return sum / @units.size
  end

  def deviation_fitness(fun)
    sum = 0.0
    avg = average_fitness(fun)
    @units.each do |unit|
      sum += Math::sqrt( (unit.fitness(fun) - avg)**2 )
    end
    return sum / (@units.size - 1)
  end

  def drop_worst_unit(fun)
    idx = nil
    worst_fit = nil 
    @units.size.times do |i|
      tmp_fit = @units[i].fitness(fun)
      if worst_fit == nil || tmp_fit < worst_fit
        idx = i
        worst_fit = tmp_fit
      end
    end
    return @units.slice!(idx)
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

  def tournament_selection(fun)
    _tournament_selection(fun, nil)
  end

  def tournament_selection!(fun)
    _tournament_selection(fun, true)
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
    # 順位は1位,2位,...とする。0位からにすると、すべてが0位になったときに
    # sumが0になってしまうので、計算エラーになってしまう
    ranked_fitnesses = [] # 順位に変換された適合度を格納
    fitnesses.each do |fit|
      ranked_fitnesses << rank.index(fit) + 1
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
    return nil
  end

  def _tournament_selection(fun, bang=nil)
    indice = (0..@units.size-1).to_a  # くじ
    units_fitness = {}
    @tournamentSize.times do |i|
      idx = indice.slice!(rand(indice.size))
      units_fitness[idx] = @units[idx].fitness(fun)
    end
    max_fit = nil
    max_idx = nil
    units_fitness.each{|idx, fit|
      if max_fit == nil || max_fit < fit
        max_fit = fit
        max_idx = idx
      end
    }

    if bang
      return @units.slice!(max_idx)
    else
      return @units[max_idx]
    end
  end
end
