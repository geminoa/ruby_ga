class Individual 
  $debug = false 

  attr_reader :age

  # You can design the gene structure as the argument 'gen'.
  # Currently, the types of gene are
  # 1. Array of boolean (You give the size of the array as 'gene_size'.)
  # 2. Array of Fixnum (You give the variation of gene as 'gene_var')
  #    [exp] If you give the variation as 3, the bits of the gene is value of 0 ~ 2
  #          like following array, [1, 0, 2, 1, 1, 2, 0 ...].
  # 3. Array of arbitrary value (You give the array directly)
  def initialize(gene_size, gene_var, genes, mutationProbability)
    @age = 0
    @gene_var = gene_var.dup
    @gene = []

    if genes == nil
      gene_size.times do |i|
        @gene << gene_var[rand(gene_var.size)]
      end
    else  # case of gen != nil
      if genes.class == Array  # Gene is the array of arbitrary value.
        @gene = genes.dup
      else  # Other types of gene is not supported, so gene is set up as default.
        gene_size.times do
          @gene << gene_var[rand(gene_var.size)]
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
  def crossover(pa, crossover_method, opt=nil)
    if pa.class != Individual
      raise "Parent's class is invalid!"
    end

    if pa.gene.size == @gene.size
      if crossover_method.class == Fixnum
        gene1, gene2 = multi_point_crossover(@gene, pa.gene, crossover_method)
      end

      case crossover_method
      when "uniform"
        gene1, gene2 = uniform_crossover(@gene, pa.gene)
      when "cut_from_left"
        gene1, gene2 = cut_from_left_crossover(@gene, pa.gene)
      when "stitch"
        gene1, gene2 = stitch_crossover(@gene, pa.gene)
      else
        raise "Crossover method is invalid!"
      end
      child1 = Individual.new(@gene.size,  @gene_var, gene1 , @mutationProbability)
      child2 = Individual.new(@gene.size,  @gene_var, gene2 , @mutationProbability)
      return child1, child2
    else
      raise "different spiecies!"
    end
  end

  # Not destructive
  # TODO @geneがboolean or Fixnum以外の場合も作成
  def mutation(mutProbability, mutation_method)
    tmp_gene = @gene.dup
    case mutation_method
    when "inversion"
      tmp_gene = mutation_inversion(tmp_gene)
    when "translocation"
      tmp_gene = mutation_translocation(tmp_gene)
    when "move"
      tmp_gene = mutation_move(tmp_gene)
    when "scramble"
      tmp_gene = mutation_scramble(tmp_gene)
    else # Examine each bit of gene whether it's changed or not.
      tmp_gene.size.times do |i|
        if rand(100) < (mutProbability*100)
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
  def mutation!(mutProbability, mutation_method)
    case mutation_method
    when "inversion"
      mutation_inversion(@gene)
    when "translocation"
      mutation_translocation(@gene)
    when "move"
      mutation_move(@gene)
    when "scramble"
      mutation_scramble(@gene)
    else  # Examine each bit of gene whether it's changed or not.
      @gene.size.times do |i|
        if rand(100) < (mutProbability*100)
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
    return Individual.new(@gene.size,  @gene_var, @gene, @mutationProbability)
  end

  private
  # 50%の確率でparent1 or parent2どちらかの遺伝子を引き継ぐ
  def uniform_crossover(ary1, ary2)
    if ary1.size != ary2.size
      raise "size of ary1,2 must be same."
    end

    ary1.size.times do |i|
      if rand(2) == 0  # 0 is returned in 50%.
        tmp = ary1[i]
        ary1[i] = ary2[i]
        ary2[i] = tmp
      end
    end
    return ary1, ary2
  end

  # 1点交叉
  def one_point_crossover(ary1, ary2)
    point = rand(ary1.size)
    child1 = ary1.slice!(0, point)
    child2 = ary2.slice!(0, point)
    child1 += ary2
    child2 += ary1
    return child1, child2
  end

  # 複数点交叉
  def multi_point_crossover(ary1, ary2, po_num)
    if po_num == 0 || po_num == 1
      one_point_crossover(ary1, ary2)
    else
      if po_num > ary1.size
        raise "too many point number! po_num must be lesser than ary size."
      end

      # Select the points for crossover.
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
      points.sort!
      points = [0] + points if points[0] != 0

      child1 = []
      child2 = []
      switch = true
      points.size.time do |pi|
        if points[pi+1] == nil
          next_index = ary1.size - 1
        else
          next_index = points[pi+1]
        end

        if switch == true
          child1 += ary1.slice(pi, next_index - pi)
          child2 += ary2.slice(pi, next_index - pi)
        else
          child1 += ary2.slice(pi, next_index - pi)
          child2 += ary1.slice(pi, next_index - pi)
        end
        switch = !switch
      end

      return child1, child2
    end
  end

  # 両親それぞれ左からn個ずつ遺伝子をとっていく
  # parent1 [a,b,c,d,e,...]
  # parent2 [A,B,C,D,E,...]
  # n = 2の場合、
  # child   [a,b,A,B,c,d,...]
  #
  # cnum: cut number.
  # dup: allow duplication or not.
  def cut_from_left_crossover(genes1, genes2, cnum=2)
    if cnum < 1
      raise 'cnum must be larger than 1.'
    end
    ary_size = genes1.size
    res_ary = []
    flg = true
    2.times do
      ary1 = genes1.dup
      ary2 = genes2.dup
      tmp_ary = []
      ary_size.times do |i|
        cnum.times do
          if flg == true
            tmp_ary << ary1.shift
          else
            tmp_ary << ary2.shift
          end
          tmp_ary.uniq!
          break if tmp_ary.size == ary_size
        end
        break if tmp_ary.size == ary_size
        flg = !flg
      end
      res_ary << tmp_ary.dup
      flg = false
    end

    child1 = res_ary[0]
    child2 = res_ary[1]
    return child1, child2
  end

  # 両親から縫うように互いにn個ずつ遺伝子をとっていく
  # parent1 [a,b,c,d,e,...]
  # parent2 [A,B,C,D,E,...]
  # n = 2の場合、
  # child   [a,b,C,D,e,f,...]
  #
  # cnum: cut number.
  # dup: allow duplication or not.
  def stitch_crossover(genes1, genes2, cnum=2)
    if cnum < 1
      raise 'cnum must be larger than 1.'
    end
    ary_size = genes1.size
    res_ary = []
    cnt = 0
    2.times do  # child1, 2で２回
      tmp_ary = []  # genes1, 2の遺伝子をcnumずつtmp_aryに入れていく
      2.times do |turn|
        switch = true
        ary_size.times do |i|
          if turn == 0  # genes1からtmp_aryに入れていく
            if switch == true
              tmp_ary << genes1[i]
            else
              tmp_ary << genes2[i]
            end
          else  # genes2からtmp_aryに入れていく
            if switch == false
              tmp_ary << genes1[i]
            else
              tmp_ary << genes2[i]
            end
          end
          cnt += 1
          if cnt == cnum  # cnum個を格納したらswitchを切り替える
            switch = !switch
            cnt = 0
          end
        end
      end
      res_ary << tmp_ary.uniq.slice(0, ary_size) # tmp_aryからary_size個だけ取り出す
    end
    child1 = res_ary[0]
    child2 = res_ary[1]
    return child1, child2
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

  # Invert genes between the two indices.
  # For example, if ary = [0,1,2,3,4,5] and indices are 2 and 4
  # then the inversion result is [0,1,4,3,2,5].
  def mutation_inversion(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1 
    while(idx1 == idx2)
      idx2 = rand(gene_ary.size)
    end
    if idx1 > idx2
      tmp_idx = idx1
      idx1 = idx2
      idx2 = tmp_idx
    end
    tmp = gene_ary.slice!(idx1, (idx2 - idx1 + 1))
    tmp.reverse!
    gene_ary.insert(idx1, tmp).flatten!

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

  # Shuffle genes between the two indices.
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
    tmp = gene_ary.slice!(idx1, (idx2 - idx1 + 1))
    tmp.shuffle!
    gene_ary.insert(idx1,tmp).flatten!
    return gene_ary
  end
end
