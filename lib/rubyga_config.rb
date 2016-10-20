class RubyGAConfig
  $defaultGeneVar = [true, false]
  $defaultGeneSize = 10
  $defaultUnitNum= 50
  $defaultSelection = "roulette"
  $defaultMutation = nil
  $defaultCrossover = "uniform"
  $defaultCrossoverProbability = 0.8
  $defaultMutationProbability = 0.05 

  # [TODO] TSPであるかどうかをconfに登録するかどうか考える

  attr_accessor :unit_num, :gene_size, :gene_var, :genes, :fitness, :selection, :mutation, :crossover, :crossoverProbability, :mutationProbability, :desc
  def initialize(
    unit_num=nil,   # Number of unit (or individual) of the population.
    gene_size=nil,  # Size of gene of an individual.
    gene_var=nil,   # Gene variation, for exp. [true,false] or [0,1,2,...].
    genes=nil,       # You can give all of the gene directory as multi-dimension array.
    fitness=nil,    # Fitness funciton.
    selection=nil,  # Selection method (roulette, rank, elite, tournament).
    mutation=nil,   # Mutation method (inversion, translocation, move, scramble or nil(examine each bit of gene to mutate) ).
    crossover=nil,  # Crossover method. Default is uniform crossover. You can give the argument as Fixnum(single or multi-point crossover).
    crossoverProbability=nil,
    mutationProbability=nil,
    desc=nil        # Description.
  )
  #if genes.class != Array
  if !(genes == nil || genes.class == Array || genes.class == File || genes.class == String)
    raise 'Class of gene must be NilClass or Array or File, String.'
  end

  if unit_num == nil
    @unit_num = $defaultUnitNum
  elsif unit_num.class == Fixnum
    @unit_num = unit_num
  else
    raise 'Class of unit_num must be Fixnum'
  end

  if genes != nil
    if genes.class == Array
      @genes = genes
    elsif genes.class == File
      str = ""
      str = genes.read
      str.gsub!(/\n+/,"\n")
      ary = []
      str.each_line{|l|
        ary << l.gsub(/\s/,"").chomp.split(',')
      }
      @genes = ary
    elsif genes.class == String
      str = ""
      open(genes){|f| str += f.read}
      str.gsub!(/\n+/,"\n")
      ary = []
      str.each_line{|l|
        ary << l.gsub(/\s/,"").chomp.split(',')
      }
      @genes = ary
    end

    # Check the class of @genes.
    if @genes.class != Array
      raise 'Class of genes must be Array.'
    end

    if gene_var != nil
      @gene_var = gene_var
    else
      if @genes[0].class == Array  # ２次元配列の場合
        @gene_var = @genes[0].uniq
      else   # 単純な配列の場合
        @gene_var = @genes.uniq
      end
    end

    if gene_size != nil
      @gene_size = gene_size
    else
      if @genes[0].class == Array  # ２次元配列の場合
        @gene_size = @genes[0].uniq.size
      else   # 単純な配列の場合
        @gene_size = @genes.uniq.size
      end
    end

  else  # case of genes == nil.
    if gene_size != nil
      @gene_size = gene_size
    else
      @gene_size = $defaultGeneSize
    end

    if gene_var != nil
      @gene_var = gene_var
    else
      @gene_var = $defaultGeneVar
    end

    @genes = []
    @unit_num.times do |i|
      @genes << generate_gene()
    end
  end

  if mutation == nil
    @mutation = $defaultMutation
  else
    @mutation = mutation
  end

  if selection == nil
    @selection = $defaultSelection
  else
    @selection = selection
  end

  if crossover == nil
    @crossover = $defaultCrossover
  else
    @crossover = crossover
  end

  if crossoverProbability == nil
    @crossoverProbability = $defaultCrossoverProbability
  else
    @crossoverProbability = crossoverProbability
  end

  if mutationProbability == nil
    @mutationProbability = $defaultMutationProbability
  else
    @mutationProbability = mutationProbability
  end

  if desc == nil
    @desc = ""
  else
    @desc = desc
  end

  end  # of initialize

  # Generate gene to give the population.
  # Arguments: 
  #   cond = condition of generating gene.
  # Condition is supposed as following,
  #   1. random (general purpose).
  #   2. tsp (it's intended for TSP(Travel Salesman Problem), so each of element appears
  #           only once in the returned array which size equals given gene. 
  #           The first element equals the last one.)
  def generate_gene(cond=nil)
    bits = []
    cond = "random" if cond == nil

    if cond == "random"
      @gene_size.times do |i|
        bits << @gene_var[rand(@gene_var.size)]
      end
    elsif cond == "tsp"
      tmp_gene = @gene_var.dup
      @gene_var.size.times do |i|
        bits << tmp_gene.slice!(rand(tmp_gene.size))
      end
      if bits.size != bits.uniq.size
        raise "Failed to generage_gene for TSP: #{bits}"
      end
    end
    return bits
  end
end
