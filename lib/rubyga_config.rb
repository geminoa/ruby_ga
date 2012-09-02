class RubyGAConfig
  $defaultGeneVar = [true, false]
  $defaultGeneSize = 50

  attr_accessor :gene_size, :gene_var, :gene, :desc
  def initialize(gene_size=nil, gene_var=nil, gene=nil, desc=nil)
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
    end

    if gene_size != nil
      @gene_size = gene_size
    elsif @gene != nil
      @gene_seze = @gene.size
    else
      @gene_size = $defaultGeneSize
    end

    if gene_var != nil
      @gene_var = gene_var
    elsif @gene != nil
      if @gene[0].class == Array  # ２次元配列の場合
        @gene_var = @gene[0].uniq
      else  # 単純な配列の場合
        @gene_var = @gene.uniq
      end
    else
      @gene_var = $defaultGeneVar
    end

    if desc == nil
      @desc = ""
    else
      @desc = desc
    end

  end

  # Generate gene to give the population.
  # Arguments: 
  #   gene_num = number of genes.
  #   cond = condition of generating gene.
  # Condition is supposed as following,
  #   1. random (general purpose).
  #   2. tsp (it's intended for TSP(Travel Salesman Problem), so each of element appears
  #           only once in the returned array which size equals given gene. 
  #           The first element equals the last one.)
  def generate_gene(gene_num, cond=nil)
    if gene_num.class != Fixnum
      raise 'Class of gene_num must be Fixnum'
    end

    genes = []
    gene_num.times do |num|
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
      genes << bits
    end
    return genes
  end
end
