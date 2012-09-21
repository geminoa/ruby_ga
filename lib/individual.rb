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
  def initialize(gene_size, gene_var, gen=nil)
    @age = 0
    @gene_var = gene_var
    @gene = []

    if gen == nil
      gene_size.times do |i|
        @gene << gene_var[rand(gene_var.size)]
      end
    else  # case of gen != nil
      if gen.class == Array  # Gene is the array of arbitrary value.
        @gene = gen.dup
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
  def crossover(pa=nil, gen_method="uniform")
    if pa.gene.size == @gene.size
      if gen_method.class == Fixnum
        gene_ary = multi_point_crossover(@gene, pa.gene, gen_method)
      else
        gene_ary = uniform_crossover(@gene, pa.gene)
      end
      return Individual.new(@gene.size,  @gene_var, gene_ary)
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
  def mutation(percentage=0.05, mutation_method=nil)
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
        puts "Error: too many point number!"
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

  # 両親それぞれ左からn個ずつ遺伝子をとっていく
  # parent1 [a,b,c,d,e,...]
  # parent2 [A,B,C,D,E,...]
  # n = 2の場合、
  # child   [a,b,A,B,c,d,...]
  #
  # cnum: cut number.
  # dup: allow duplication or not.
  def cut_from_left_crossover(orig_ary1, orig_ary2, cnum=3, dup=false)
    if cnum < 1
      raise 'cnum must be larger than 1.'
    end
    ary1 = orig_ary1.dup
    ary2 = orig_ary2.dup
    ary_size = ary1.size
    res_ary = []
    flg = true
    while(res_ary.size < ary_size)
      cnum.times do |i|
        if flg == true
          res_ary << ary1.shift
        else
          res_ary << ary2.shift
        end
        res_ary.uniq!
        break if res_ary.size == ary_size
      end
      break if res_ary.size == ary_size
      flg = !flg
    end
    return res_ary
  end

  # 両親から縫うように互いにn個ずつ遺伝子をとっていく
  # parent1 [a,b,c,d,e,...]
  # parent2 [A,B,C,D,E,...]
  # n = 2の場合、
  # child   [a,b,C,D,e,f,...]
  #
  # cnum: cut number.
  # dup: allow duplication or not.
  def stitch_crossover(ary1, ary2, cnum=3, dup=false)
    if cnum < 1
      raise 'cnum must be larger than 1.'
    end
    ary_size = ary1.size
    tmp_ary = []
    flg = true
    cnt = 0
    2.times do |turn|
      ary_size.times do |i|
        if turn == 0
          if flg == true
            tmp_ary << ary1[i]
          else
            tmp_ary << ary2[i]
          end
        else
          if flg == false
            tmp_ary << ary1[i]
          else
            tmp_ary << ary2[i]
          end
        end
        cnt += 1
        if cnt == cnum
          flg = !flg
          cnt = 0
        end
      end
    end
    res_ary = tmp_ary.slice!(0, ary_size)
    res_ary.uniq!
    until(res_ary.size == ary_size)
      res_ary << tmp_ary.shift
      res_ary.uniq!
    end
    return res_ary
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
