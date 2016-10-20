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
  return ch1, ch2
end


# Reduce partial map by extracting first key and last value.
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
  return child1, child2
end


# CX
cx_parents = [
  [8, 4, 7, 3, 6, 2, 5, 1, 9, 0],
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
]


# PMX
pmx_parents = [
#  [1,2,3,4,5,6,7,8,9],
#  [4,5,2,1,8,7,6,9,3]
  [1, 2, 3, 4, 5, 6, 7],
  [5, 4, 6, 7, 2, 1, 3]
]

#p uniform_crossover(cx_parents[0], cx_parents[1])
#p cycle_crossover(cx_parents[0], cx_parents[1])
p partially_mapped_crossover(pmx_parents[0], pmx_parents[1], po_num=2, p1=2, p2=6)
