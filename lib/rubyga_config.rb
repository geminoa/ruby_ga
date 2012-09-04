class RubyGAConfig
  $defaultGeneVar = [true, false]
  $defaultGeneSize = 10
  $defaultUnitNum= 50
  $defaultSelection = "roulette"
  $defaultMutation = nil
  $defaultCrossover = "uniform"

  attr_accessor :unit_num, :gene_size, :gene_var, :gene, :fitness, :selection, :mutation, :crossover, :desc
  def initialize(
    unit_num=nil,   # Number of unit (or individual) of the population.
    gene_size=nil,  # Size of gene of an individual.
    gene_var=nil,   # Gene variation, for exp. [true,false] or [0,1,2,...].
    gene=nil,       # You can give all of the gene directory as multi-dimension array.
    fitness=nil,    # Fitness funciton.
    selection=nil,  # Selection method (roulette, rank, elite, tournament).
    mutation=nil,   # Mutation method (inversion, translocation, move, scramble or nil(examine each bit of gene to mutate) ).
    crossover=nil,  # Crossover method. Default is uniform crossover. You can give the argument as Fixnum(single or multi-point crossover).
    desc=nil        # Description.
  )
  #if gene.class != Array
  if !(gene == nil || gene.class == Array || gene.class == File || gene.class == String)
    raise 'Class of gene must be NilClass or Array or File, String.'
  end

  if gene != nil
    if gene.class == Array
      @gene = gene
    elsif gene.class == File
      str = ""
      str = gene.read
      str.gsub!(/\n+/,"\n")
      ary = []
      str.each_line{|l|
        ary << l.gsub(/\s/,"").chomp.split(',')
      }
      @gene = ary
    elsif gene.class == String
      str = ""
      open(gene){|f| str += f.read}
      str.gsub!(/\n+/,"\n")
      ary = []
      str.each_line{|l|
        ary << l.gsub(/\s/,"").chomp.split(',')
      }
      @gene = ary
    end

    # Check the class of @gene.
    if @gene.class != Array
      raise 'Class of gene must be Array.'
    end

    if gene_var != nil
      @gene_var = gene_var
    else
      if @gene[0].class == Array  # ２次元配列の場合
        @gene_var = @gene[0].uniq
      else   # 単純な配列の場合
        @gene_var = @gene.uniq
      end
    end

    if gene_size != nil
      @gene_size = gene_size
    else
      if @gene[0].class == Array  # ２次元配列の場合
        @gene_var = @gene[0].uniq
      else   # 単純な配列の場合
        @gene_var = @gene.uniq
      end
    end

  else  # case of gene == nil.
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
  end

  if unit_num == nil
    @unit_num = $defaultUnitNum
  elsif unit_num.class == Fixnum
    @unit_num = unit_num
  else
    raise 'Class of unit_num must be Fixnum'
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

  if desc == nil
    @desc = ""
  else
    @desc = desc
  end

  end

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
    end
  end
end
