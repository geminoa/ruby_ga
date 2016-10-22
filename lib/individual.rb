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
  def initialize(gene_size, gene_var, gene, mutationProbability)
    @age = 0
    @gene_var = gene_var.dup
    @gene = []

    if gene == nil
      gene_size.times do |i|
        @gene << gene_var[rand(gene_var.size)]
      end
    else  # case of gen != nil
      if gene.class == Array  # Gene is the array of arbitrary value.
        @gene = gene.dup
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

      #puts "before gene.size: #{@gene.size}"  # debug
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
      when "cycle"  # for TSP
        gene1, gene2 = cycle_crossover(@gene, pa.gene)
      when "partially_mapped"  # for TSP
        gene1, gene2 = partially_mapped_crossover(@gene, pa.gene)
      when "non_wrapping_ordered"  # for TSP
        gene1, gene2 = non_wrapping_ordered_crossover(@gene, pa.gene)
      when "ordered"  # for TSP
        gene1, gene2 = ordered_crossover(@gene, pa.gene)
      else
        raise "Crossover method is invalid!"
      end
      #puts "after gene.size: #{@gene.size}"  # debug
      #puts "gene1.size: #{gene1.size}"  # debug
      #puts "gene2.size: #{gene2.size}"  # debug
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
      tmp_gene = inversion_mutation(tmp_gene)
    when "translocation"
      tmp_gene = translocation_mutation(tmp_gene)
    when "move"
      tmp_gene = move_mutation(tmp_gene)
    when "scramble"
      tmp_gene = scramble_mutation(tmp_gene)
    when "twors"  # for TSP
      tmp_gene = twors_mutation(tmp_gene)
    when "center_inverse"  # for TSP
      tmp_gene = center_inverse_mutation(tmp_gene)
    when "reverse_sequence"  # for TSP
      tmp_gene = reverse_sequence_mutation(tmp_gene)
    when "throas"  # for TSP
      tmp_gene = throas_mutation(tmp_gene)
    when "thrors"  # for TSP
      tmp_gene = thrors_mutation(tmp_gene)
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
      inversion_mutation(@gene)
    when "translocation"
      translocation_mutation(@gene)
    when "move"
      move_mutation(@gene)
    when "scramble"
      scramble_mutation(@gene)
    when "twors"  # for TSP
      twors_mutation(@gene)
    when "center_inverse"  # for TSP
      center_inverse_mutation(@gene)
    when "reverse_sequence"  # for TSP
      reverse_sequence_mutation(@gene)
    when "throas"  # for TSP
      throas_mutation(@gene)
    when "thrors"  # for TSP
      thrors_mutation(@gene)
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
  # Children are inherit each of elements of gene from parent1, 2 in 50%.
  def uniform_crossover(gene1, gene2)
    if gene1.size != gene2.size
      raise "Different gene size."
    end

    tmp1 = gene1.dup
    tmp2 = gene2.dup
    tmp1.size.times do |i|
      if rand(2) == 0  # 0 is returned in 50%.
        tmp = tmp1[i]
        tmp1[i] = tmp2[i]
        tmp2[i] = tmp
      end
    end
    return tmp1, tmp2
  end


  # One point crossover
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


  # Multi point crossover
  # gene is divided by points of the number of po_num.
  def multi_point_crossover(gene1, gene2, po_num=2)
    case po_num
    when 0
      raise "You must give 1 or more value for po_num."
    when 1
      return one_point_crossover(gene1, gene2)
    when (gene1.size - 1) # same as stitch_crossover with cnum=1.
      return stitch_crossover(gene1, gene2, 1)
    else # Decide which positions for crossover in random.
      if po_num >= gene1.size
        raise "Too many points! po_num must be less than gene size."
      end

      points = []
      # Duplicate gene1 and gene2 to avoid destructed by slice! method.
      # [memo] It doesn't need if there is no destructive methods for gene1, 2.
      tmp1 = gene1.dup
      tmp2 = gene2.dup

      # points in random.
      tmp_p = (1..tmp1.size).to_a
      while (points.size < po_num)
        points << tmp_p.delete_at(rand(tmp_p.size))
      end
      points.sort!

      child1 = []
      child2 = []
      flg = true
      # Add 0 to head and points.size to tails for using them as index of slice.
      points.unshift 0
      points.push tmp1.size
      #p points # debug
      (points.size - 1).times do |idx|
        p_from = points[idx]
        nof_p= points[idx+1] - points[idx] # num of points to slice
        #puts "from:#{p_from}, num of p:#{nof_p}"  # debug
        if flg == true
          child1 += tmp1.slice(p_from, nof_p)
          child2 += tmp2.slice(p_from, nof_p)
        else
          child1 += tmp2.slice(p_from, nof_p)
          child2 += tmp1.slice(p_from, nof_p)
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
  def cut_from_left_crossover(gene1, gene2, cnum=2)
    if cnum > gene1.size/2
      raise 'cnum must be lower than half of gene size.'
    end

    # Duplicate pa1 and pa2 to avoid destructed by slice! method.
    ary1 = gene1.dup
    ary2 = gene2.dup
    tmp_container = []  # contains all cut gene. separated to child1 and 2.
    flg = true
    while (ary2.size > 0)
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
  def stitch_crossover(gene1, gene2, cnum=2)
    if cnum < 1
      raise 'cnum must be larger than 1.'
    end

    tmp1 = gene1.dup
    tmp2 = gene2.dup
    child1 = []
    child2 = []
    flg = true
    while (tmp1.size > 0)
      if flg
        child1 = child1 + tmp1.slice!(0, 2)
        child2 = child2 + tmp2.slice!(0, 2)
      else
        child1 = child1 + tmp2.slice!(0, 2)
        child2 = child2 + tmp1.slice!(0, 2)
      end
      flg = !flg
    end
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


  # Cycle Crossover for TSP
  # parent1 = [8, 4, 7, 3, 6, 2, 5, 1, 9, 0]
  # parent2 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  # 
  # child1 = [8, 1, 2, 3, 4, 5, 6, 7, 9, 0]
  # child2 = [0, 4, 7, 3, 6, 2, 5, 1, 8, 9]
  def cycle_crossover(gene1, gene2)  # for TSP
    if gene1.size != gene2.size
      raise "Different gene type!"
    end

    idx_ary = [0]
    p2_n = gene2[0]

    until (idx_ary.size > 1) and (idx_ary[0] == idx_ary[-1])
      idx_ary << gene1.find_index(p2_n)
      p2_n = gene2[gene1.find_index(p2_n)]
    end
    idx_ary.pop  # remove nouse last index which is same sa first.
    #p idx_ary

    ary =  Array.new(gene1.size)  # ary = [nil, nil, ..., nil]
    idx_ary.each do |idx|
      ary[idx] = true
    end

    ch1, ch2 = [], []
    ary.each.with_index do |a, i|
      if a == true
        ch1[i] = gene1[i]
        ch2[i] = gene2[i]
      else
        ch1[i] = gene2[i]
        ch2[i] = gene1[i]
      end
    end

    if (ch1.uniq.size != gene1.size) or (ch2.uniq.size != gene2.size)
      raise "Error: Failed to gen children, #{child1.uniq.size}, #{child2.uniq.size}"
    end
    return ch1, ch2
  end


  # Reduce partial map for PMX by extracting first key and last value.
  # Given hash is reduced recursively.
  # {1=>2, 2=>3, 3=>4}
  # -> {1=>3, 3=>4}
  # -> {1=>4}
  def reduce_partial_map(h, k, v)
    if h[v] == nil  # last value
      return h
    end

    # remove intermediate key by replacing it value
    h[k] = h[v]  # replace value
    h.delete v   # remove key

    # call it recursively with reduced hash
    reduce_partial_map(h, k, v)
  end

  
  # Partially Mapped Crossover (PMX)
  #   gene1,2 : parents' gene
  #   po_num : points for splitting gene
  # Arguments p1 and p2 are splitting points for debugging.
  # If you give genes and p1, p2 directly,
  #   gene1 = [1, 2, 3, 4, 5, 6, 7]
  #   gene2 = [5, 4, 6, 7, 2, 1, 3]
  #   p1 = 2, p2 = 5
  # p1 and p2 split genes after 2nd element and 6th
  #   gene1 = [1, 2 | 3, 4, 5, 6 | 7]
  #   gene2 = [5, 4 | 6, 7, 2, 1 | 3]
  # and you get children as following .
  #   child1 = [3, 5, 6, 7, 2, 1, 4]
  #   child2 = [2, 7, 3, 4, 5, 6, 1]
  def partially_mapped_crossover(gene1, gene2, po_num=2, p1=nil, p2=nil)
    if p1 != nil and p2 != nil
      p1 = p1
      p2 = p2
    elsif po_num == 1
      p1 = rand(gene1.size - 1) + 1
      p2 = gene1.size
    elsif po_num == 2
      p1 = rand(gene1.size - 1) + 1
      p2 = rand(gene1.size - 1) + 1
      while p1 == p2
        p2 = rand(gene1.size - 1) + 1
      end
      if p1 > p2
        tmp = p1
        p1 = p2
        p2 = tmp
      end
    else
      raise "po_num must be 1 or 2!"
    end
    #p p1, p2

    # Extract partial gene for creating map
    tmp1 = gene1.dup
    tmp2 = gene2.dup
    ary1 = tmp1.slice(p1, p2-p1)
    ary2 = tmp2.slice(p1, p2-p1)

    # Create partial map
    # Map must be bi-directional, so create uni-directional map first. Then make it bi-directional.
    pre_map = {}  # uni-directional map
    ary1.size.times do |i|
      pre_map[ary2[i]] = ary1[i]
    end
    #p pre_map

    # Clean map by reducing intermediate elements
    tmph = pre_map.dup
    pre_map.each do |key, val|
      reduce_partial_map(tmph, key, val)
    end
    partial_map = {}  # bi-directional map
    [tmph, tmph.invert].each do |h|
      h.each do |k,v|
        partial_map[k] = v
      end
    end
    #p partial_map

    child1 = []
    child2 = []
    gene1.size.times do |i|
      if (i < p1) or (p2-1 < i)  # elements are replaced with map
        if partial_map[gene1[i]] != nil
          child1[i] = partial_map[gene1[i]]
        else
          child1[i] = gene1[i]
        end

        if partial_map[gene2[i]] != nil
          child2[i] = partial_map[gene2[i]]
        else
          child2[i] = gene2[i]
        end
      else  # replaced without map
        child1[i] = ary2[i - p1]
        child2[i] = ary1[i - p1]
      end
    end 
    if (child1.uniq.size != gene1.size) or (child2.uniq.size != gene2.size)
      #p gene1.uniq.size, gene2.uniq.size
      #p child1, child2
      raise "Error: Failed to gen children, #{child1.uniq.size}, #{child2.uniq.size}"
    end
    return child1, child2
  end


  # [TODO]
  def non_wrapping_ordered_crossover(gene1, gene2)  # for TSP
    child1, child2 = nil, nil
    return child1, child2
  end


  # [TODO]
  def ordered_crossover(gene1, gene2)  # for TSP
    child1, child2 = nil, nil
    return child1, child2
  end


  # Invert gene between the two indices.
  # For example, if ary = [0,1,2,3,4,5] and indices are 2 and 4
  # then the inversion result is [0,1,4,3,2,5].
  def inversion_mutation(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1 
    while (idx1 == idx2)
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


  def translocation_mutation(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1
    while (idx1 == idx2)
      idx2 = rand(gene_ary.size)
    end
    idx3 = idx2
    while (idx1 == idx3 || idx2 == idx3)
      idx3 = rand(gene_ary.size)
    end
    idx4 = idx3
    while (idx1 == idx4 || idx2 == idx4 ||idx3 == idx4)
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


  def move_mutation(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1 
    while (idx1 == idx2)
      idx2 = rand(gene_ary.size)
    end
    tmp = gene_ary.slice!(idx2)
    gene_ary.insert(idx1, tmp)
    return gene_ary
  end


  # Shuffle gene between the two indices.
  def scramble_mutation(gene_ary)
    idx1 = rand(gene_ary.size)
    idx2 = idx1 
    while (idx1 == idx2)
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


  # TWORS Mutation which is select two elements and exchange them.
  # For example, [1,2,3,4,5,6] -> [1,4,3,2,5,6] in which 2 and 4 are exchanged
  def twors_mutation(gene_ary)  # for TSP
    idx1 = rand(gene_ary.size)
    idx2 = rand(gene_ary.size)
    while idx1 == idx2
      idx2 = rand(gene_ary.size)
    end
    tmp = gene_ary[idx1]
    gene_ary[idx1] = gene_ary[idx2]
    gene_ary[idx2] = tmp

    return gene_ary
  end


  # Center Inverse Mutation (CIM)
  # Separate gene in two parts, then reverse each of parts.
  # [1,2,3,4,5,6] -> [1,2,3,4 | 5,6] -> [4,3,2,1 | 6,5]
  def center_inverse_mutation(gene_ary)
    tmp_ary = gene_ary.dup
    pos = rand(gene_ary.size - 1) + 1  # position for separation
    ary1 = tmp_ary.slice!(0, pos)
    return ary1.reverse + tmp_ary.reverse
  end


  # Reverse Sequence Mutation (RSM)
  # Select two points for dividing gene in three parts, reverse middle one
  # [1,2,3,4,5,6] -> [1 | 2,3,4,5 | 6] -> [1 | 5,4,3,2 | 6]
  def reverse_sequence_mutation(gene_ary)  # for TSP
    pos1 = rand(gene_ary.size - 1) + 1
    pos2 = rand(gene_ary.size - 1) + 1
    while pos1 == pos2
      pos2 = rand(gene_ary.size - 1) + 1
    end
    if pos1 > pos2
      tmp = pos1
      pos1 = pos2
      pos2 = tmp
    end

    tmp_ary = gene_ary.dup
    ary1 = tmp_ary.slice!(0, pos1)
    ary2 = tmp_ary.slice!(0, pos2 - pos1)
    res = ary1 + ary2.reverse + tmp_ary

    if res.uniq.size != gene_ary.size
      raise "Failed mutation: #{res}"
    end

    return res
  end


  # Throas Mutation
  # Select three elements of gene. the first is selected randomly and the two
  # others are those two successors. Then, the last becomes the first of the sequence, the
  # second becomes last and the first becomes the second in the sequence.  
  # [1,2,3,4,5,6] -> [1,4,3,2,5,6]
  # [TODO]
  def throas_mutation(gene_ary)
  end


  # Thrors Mutation
  # Three genes are chosen randomly which shall take the different positions not
  # necessarily successive i < j < l. the gene of the position i becomes in the position j
  # and the one who was at this position will take the position l and the gene that has
  # held this position takes the position i. 
  # [1,2,3,4,5,6] -> [1,6,3,2,5,4]
  #    ^   ^   ^        ^   ^   ^
  # [TODO]
  def thrors_mutation(gene_ary)
  end
end
