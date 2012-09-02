class RubyGAConfig
  $defaultGeneVar = [true, false]
  $defaultGeneSize = 50

  attr_accessor :gene_size, :gene_var, :gene, :desc
  def initialize(gene_size=nil, gene_var=nil, gene=nil, desc=nil)
    if gene != nil || gene.class != Array
      raise 'Class of gene must be Nil or Array.'
    end

    if desc == nil
      @desc = ""
    else
      @desc = desc
    end

    if gene_size != nil
      @gene_size = gene_size
    elsif gene != nil
      @gene_size = gene.size
    else
      @gene_size = $defaultGeneSize
    end

    if gene_var != nil
      @gene_var = gene_var
    elsif gene != nil
      @gene_var = gene.uniq
    else
      @gene_var = $defaultGeneVar
    end
  end

  # Generate gene to give the population.
  # Arguments: 
  #   gene_num = number of genes.
  #   cond = condition of generating gene.
  # Condition is supposed as following,
  #   1. random (general purpose).
  #   2. unique (it's intended for TSP(Travel Salesman Problem), so
  #              each of element appears only once in the returned 
  #              array which size equals given gene.)
  def generate_gene(gene_num, cond=nil)
    if gene_num.class != Fixnum
      raise 'Class of gene_num must be Fixnum'
    end

    gene_num.times do |num|
      bits = []
      cond = "random" if cond == nil

      if cond == "random"
        @gene_size.times do |i|
          bits << @gene_var[rand(@gene_var.size)]
        end
      elsif cond == "unique"
        if gene.class != Array
          raise 'You must give a gene as Array at initialize when the condition is "unique".'
        end

        tmp_gene = @gene.dup
        @gene.size.times do |i|
          bits << tmp_gene.slice!(rand(tmp_gene.size))
        end
      end
    end
    return bits
  end
end
