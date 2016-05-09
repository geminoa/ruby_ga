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
  def change_variation(var)
    @geneVariation = var
  end

  def gene_size
    return @gene.size
  end

  # Return duplicated array.
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

      puts "before gene.size: #{@gene.size}"
      case crossover_method
      when "uniform"
        gene1, gene2 = uniform_crossover(@gene, pa.gene)
      when "cut_from_left"
        gene1, gene2 = cut_from_left_crossover(@gene, pa.gene)
      when "stitch"
        gene1, gene2 = stitch_crossover(@gene, pa.gene)
      when "one_point"
        gene1, gene2 = one_point_crossover(@gene, pa.gene)
      when "multi_point"
        gene1, gene2 = multi_point_crossover(@gene, pa.gene)
      else
        raise "Crossover method is invalid!"
      end
      puts "after gene.size: #{@gene.size}"
      puts "gene1.size: #{gene1.size}"
      puts "gene2.size: #{gene2.size}"
      child1 = Individual.new(@gene.size, @gene_var, gene1 , @mutationProbability)
      child2 = Individual.new(@gene.size, @gene_var, gene2 , @mutationProbability)
      return child1, child2
    else
      raise "different spiecies!"
    end
  end

  # No destructive
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

  # Duplicate self object.
  def dup
    return Individual.new(@gene.size,  @gene_var, @gene, @mutationProbability)
  end

  private
  # 50%の確率でparent1 or parent2どちらかの遺伝子を引き継ぐ
  def uniform_crossover(gene1, gene2)
    if gene1.size != gene2.size
      raise "size of gene1 and gene2 must be same."
    end

    gene1.size.times do |i|
      if rand(2) == 0  # 0 is returned in 50%.
        tmp = gene1[i]
        gene1[i] = gene2[i]
        gene2[i] = tmp
      end
    end
    return gene1, gene2
  end

  # 1点交叉
  def one_point_crossover(gene1, gene2)
    # Duplicate gene1 and gene2 to avoid destructed by slice! method.
    tmp1 = gene1.dup
    tmp2 = gene2.dup

    point = rand(tmp1.size - 2) + 1  # except first and last one.
    child1 = tmp1.slice!(0, point)
    child2 = tmp2.slice!(0, point)
    child1 += tmp2
    child2 += tmp1
    return child1, child2
  end

  # 複数点交叉
  def multi_point_crossover(gene1, gene2, po_num=2)
    # [TODO] Replace if statement to case stat.
    if po_num == 0 
      raise "You must give 1 or more value for po_num."
    elsif po_num == 1
      return one_point_crossover(gene1, gene2)
    elsif po_num == (gene1.size - 1) # same as stitch_crossover with cnum=1.
      return stitch_crossover(gene1, gene2, 1)
    elsif po_num >= gene1.size 
      raise "Too many points! po_num must be less than gene size."
    else # Decide which positions for crossover in random.
      points = []
      # Duplicate gene1 and gene2 to avoid destructed by slice! method.
      # [memo] It doesn't need if there is no destructive methods for gene1, 2.
      tmp1 = gene1.dup
      tmp2 = gene2.dup

      # Decide multi points in random.
      tmp_p = (1..tmp1.size).to_a
      while points.size < po_num
        points << tmp_p.delete_at(rand(tmp_p.size))
      end
      points.sort!

      child1 = []
      child2 = []
      flg = true
      # Add 0 to head and points.size to tails for using them as index of slice.
      # [TODO] sliceの使い方が間違っている！修正！
      points.unshift 0
      points.push tmp1.size
      p points # debug
      (points.size - 1).times do |idx|
        p_from = points[idx]
        p_to = points[idx+1] - 1
        puts "from:#{p_from}, to:#{p_to}"  # debug
        if flg == true
          child1 += tmp1.slice(p_from, p_to)
          child2 += tmp2.slice(p_from, p_to)
        else
          child1 += tmp2.slice(p_from, p_to)
          child2 += tmp1.slice(p_from, p_to)
        end
        flg = !flg
      end
      return child1, child2
    end
  end

  # 両親それぞれ左からn個ずつ遺伝子をとっていく
  # cnumは遺伝子サイズの半分以下出なければならない
  # parent1 [a,b,c,d,e,...]
  # parent2 [A,B,C,D,E,...]
  # n = 2の場合、
  # child1   [a,b,A,B,c,d,...]
  # child2   [i,j,I,J,k,l,...]
  #
  # cnum: cut number.
  # dup: allow duplication or not.
  def cut_from_left_crossover(genes1, genes2, cnum=2)
    if cnum > genes1.size/2
      raise 'cnum must be lower than half of gene size.'
    end
    
    # Duplicate pa1 and pa2 to avoid destructed by slice! method.
    ary1 = genes1.dup
    ary2 = genes2.dup
    tmp_container = []  # contains all cut genes. separated to child1 and 2.
    flg = true
    while ary2.size > 0
      if flg == true
        tmp_container << ary1.slice!(0, cnum)
        flg = !flg
      else
        tmp_container << ary2.slice!(0, cnum)
        flg = !flg
      end
    end

    tmp_container.flatten!
    child1 = tmp_container.slice!(0, tmp_container.size/2)
    child2 = tmp_container
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
