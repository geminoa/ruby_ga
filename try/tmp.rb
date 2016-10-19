#!/usr/bin/env ruby

def uniform_crossover(gene1, gene2)
  if gene1.size != gene2.size
    raise "size of gene1 and gene2 must be same."
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

# parent1 = [8, 4, 7, 3, 6, 2, 5, 1, 9, 0]
# parent2 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
# 
# child1 = [8, 1, 2, 3, 4, 5, 6, 7, 9, 0]
# child2 = [0, 4, 7, 3, 6, 2, 5, 1, 8, 9]
#
def cycle_crossover(gene1, gene2)
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
  p idx_ary

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
  return ch1, ch2
end


# Each of parents are divided into three parts.
# Then, first and third parts are inherited to children.
# The second part is only used for relation table as following
# parent1 = [1, 2, 3, 4, 5, 6, 7]
# parent2 = [5, 4, 6, 7, 2, 1, 3]
# 
# child1 = [3, 5, 6, 7, 2, 1, 2]
# child2 = [2, 7, 3, 4, 5, 6, 1]
def partially_mapped_crossover(gene1, gene2, po_num=2)
  p1 = 2, p2 = 5
  
end


# CX
parent1 = [8, 4, 7, 3, 6, 2, 5, 1, 9, 0]
parent2 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

# PMX
parent1 = [1, 2, 3, 4, 5, 6, 7]
parent2 = [5, 4, 6, 7, 2, 1, 3]

#p uniform_crossover(parent1, parent2)
#p parent1, parent2
p cycle_crossover(parent1, parent2)
