class Individual 

  $defaultGeneSize = 50
  $debug = false 

  attr_reader :age

  # You can design the gene structure as the argument 'gen'.
  # Currently, the types of gene are
  # 1. Array of boolean (You give the size of the array as 'gen_size', or the size
  #    is $defaultGeneSize if the size is not given)
  # 2. Array of Fixnum (You give the variation of gene as 'gen_var')
  #    [exp] If you give the variation as 3, the bits of the gene is value of 0 ~ 2
  #          like following array, [1, 0, 2, 1, 1, 2, 0 ...].
  # 3. Array of arbitrary value (You give the array directly)
  def initialize(gen=nil, gen_size=nil, gen_var=nil)
    @age = 0
    @gene = []
    @geneVariation = nil

    if gen == nil  # Gene is boolean array of the default size.
      if gen_size == nil
        gen_size = $defaultGeneSize
      else
        if gen_size.class != Fixnum
          raise "Invalid argument. 'gen_size' must be Fixnum."
        end
      end

      if gen_var == nil  # @gene is initialized as Array of boolean.
        @geneVariation = 2
      elsif gen_var.class == Fixnum
        @geneVariation = gen_var
      else
        raise "Invalid argument. 'gen_var' must be Fixnum."
      end

      gen_size.times do |i|
        if gen_var == nil
          if rand(2) == 0
            @gene << true
          else
            @gene << false
          end
        else
          @gene << rand(@geneVariation)
        end
      end
    else  # case of gen != nil
      if gen.class == Array  # Gene is the array of arbitrary value.
        @gene = gen.dup
      else  # Other types of gene is not supported, so gene is set up as default.
        $defaultGeneSize.times do
          if rand(2) == 0
            @gene << true
          else
            @gene << false
          end
        end
      end
    end
  end

  # Change @geneVariation to the var.
  # 使うかな？
  def change_variation(var)
    @geneVariation = var
  end

  def gene_size
    return @gene.size
  end

  # To avoid original @gene, return duplicated array.
  def gene
    return @gene.dup
  end

  def fitness(fun)
    return fun.call(@gene)
  end

  # Increment age.
  def get_older
    @age += 1
  end

  # Generate new generation individual.
  def crossover(pa=nil, gen_method="default")
    if pa.gene.size == @gene.size
      if gen_method.class == Fixnum
        gene_ary = multi_point_crossover(@gene, pa.gene, gen_method)
      else
        gene_ary = uniform_crossover(@gene, pa.gene)
      end
      return Individual.new(gene_ary)
    else
      return "different spiecies!"
    end
  end

  # Each bit of first parent is checked with bit of second parent whether they are same.
  # If same then the bit is taken for the offspring otherwise the bit from the third parent
  # is taken for the offspring.
  def three_parent_crossover(ary1, ary2, ary3)
    tmp_ary = []
    ary1.size.times do |i|
      if ary1[i] == ary2[i]
        tmp_ary[i] = ary2[i]
      else
        tmp_ary[i] = ary3[i]
      end
    end
    return tmp_ary
  end

  # Not destructive
  # TODO @geneがboolean or Fixnum以外の場合も作成
  def mutation(percentage=0.05, method=nil)
    tmp_gene = @gene.dup
    if method == "inversion"
      tmp_gene = mutation_inversion(tmp_gene)
    elsif method == "translocation"
      tmp_gene = mutation_translocation(tmp_gene)
    elsif method == "move"
      tmp_gene = mutation_move(tmp_gene)
    elsif method == "scramble"
      tmp_gene = mutation_scramble(tmp_gene)
    else # Examine each bit of gene whether it's changed or not.
      tmp_gene.size.times do |i|
        if rand(100) < (percentage*100)
          if (tmp_gene[i] == true || tmp_gene[i] == false)
            tmp_gene[i] = !tmp_gene[i]
          elsif tmp_gene[i].class == Fixnum
            tmp_gene[i] = rand(@geneVariation)
          end
        end
      end
    end
    return tmp_gene
  end

  # Destructive
  # TODO @geneがboolean or Fixnum以外の場合も作成
  def mutation!(percentage=0.05, method=nil)
    if method == "inversion"
      mutation_inversion(@gene)
    elsif method == "translocation"
      mutation_translocation(@gene)
    elsif method == "move"
      mutation_move(@gene)
    elsif method == "scramble"
      mutation_scramble(@gene)
    else  # Examine each bit of gene whether it's changed or not.
      @gene.size.times do |i|
        if rand(100) < (percentage*100)
          if (@gene[i] == true || @gene[i] == false)
            @gene[i] = !@gene[i]
          else
            @gene[i] = rand(@geneVariation)
          end
        end
      end
    end
    return true
  end

  def dup
    return Individual.new(@gene.dup)
  end

  private
  def uniform_crossover(ary1, ary2)
    tmp_ary = []
    ary1.size.times do |i|
      if rand(2) == 0  # 0 is returned in 50%.
        tmp_ary << ary1[i]
      else
        tmp_ary << ary2[i]
      end
    end
    return tmp_ary
  end

  def one_point_crossover(ary1, ary2)
    point = rand(ary1.size)
    return ary1[0..(point)] + ary2[(point+1)..(ary2.size-1)]
  end

  def multi_point_crossover(ary1, ary2, po_num)
    if po_num == 0 || po_num == 1
      one_point_crossover(ary1, ary2)
    else
      if po_num > ary1.size
        puts "Error: too many numbers!"
        return nil
      end

      points = []
      if po_num == ary1.size
        po_num.times do |i|
          points << i
        end
      else
        po_num.times do |i|
          points << rand(ary1.size)
        end
        points.uniq!

        while(points.size < po_num)
          points << rand(ary1.size)
          points.uniq!
        end
      end

      res_ary = []
      tmp_switch = true
      tmp_switch = false if rand(2) == 0
      sorted_points = points.sort
      puts "sorted: #{sorted_points}" if $debug
      sorted_points.size.times do |pi|
        tmp_ary = nil
        if tmp_switch == true 
          if pi == 0
            res_ary += ary1[0..sorted_points[0]]
          else
            tmp_ary = ary1[sorted_points[pi-1]..sorted_points[pi]]
            tmp_ary.shift
            puts "ary1: #{sorted_points[pi-1]..sorted_points[pi]}" if $debug
            res_ary += tmp_ary
          end
          tmp_switch = false
        else
          if pi == 0
            res_ary += ary2[0..sorted_points[0]]
          else
            tmp_ary = ary2[sorted_points[pi-1]..sorted_points[pi]]
            tmp_ary.shift
            puts "ary2: #{sorted_points[pi-1]..sorted_points[pi]}" if $debug
            res_ary += tmp_ary
          end
          tmp_switch = true
        end
      end

      tmp_ary = nil
      if tmp_switch == true
        tmp_ary = ary1[sorted_points.last..(ary1.size-1)]
      else
        tmp_ary = ary2[sorted_points.last..(ary2.size-1)]
      end
      tmp_ary.shift
      res_ary += tmp_ary

      return res_ary
    end
  end

  def mutation_inversion(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1 
    while(idx1 == idx2)
      idx2 = rand(gene_ary.size)
    end
    tmp1 = gene_ary[idx1]
    tmp2 = gene_ary[idx2]
    gene_ary[idx1] = tmp2
    gene_ary[idx2] = tmp1
    return gene_ary
  end

  def mutation_translocation(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1
    while(idx1 == idx2)
      idx2 = rand(gene_ary.size)
    end
    idx3 = idx2
    while(idx1 == idx3 || idx2 == idx3)
      idx3 = rand(gene_ary.size)
    end
    idx4 = idx3
    while(idx1 == idx4 || idx2 == idx4 ||idx3 == idx4)
      idx4 = rand(gene_ary.size)
    end
    # swap idx1 and idx3.
    tmp1 = gene_ary[idx1]
    tmp2 = gene_ary[idx3]
    gene_ary[idx1] = tmp2
    gene_ary[idx3] = tmp1

    # swap idx2 and idx4.
    tmp1 = gene_ary[idx2]
    tmp2 = gene_ary[idx4]
    gene_ary[idx2] = tmp2
    gene_ary[idx4] = tmp1
    return gene_ary
  end

  def mutation_move(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1 
    while(idx1 == idx2)
      idx2 = rand(gene_ary.size)
    end
    tmp = gene_ary.slice!(idx2)
    gene_ary.insert(idx1, tmp)
    return gene_ary
  end

  def mutation_scramble(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1 
    while(idx1 == idx2)
      idx2 = rand(gene_ary.size)
    end
    if idx1 > idx2 # sort indicis.
      tmp = idx1
      idx1 = idx2
      idx2 = tmp
    end
    tmp = gene_ary.slice!(idx1, idx2)
    tmp.shuffle!
    gene_ary.insert(idx1,tmp).flatten!
    return gene_ary
  end
end
