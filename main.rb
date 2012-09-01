require "ruby_ga"
require "pp"

def count_true(ary)
  sum = 0
  ary.each do |a|
    sum += 1 if a == true
  end
  return sum
end

def main
  ["roulette", "elite", "tournament", "rank"].each do |sel|
    gpl_cmd = "plot"
    ["inversion", "translocation", "move", "scramble", "else"].each do |mut|
      po = Population.new 50
      fun = method(:count_true)
      p po.average_fitness(fun)
      file = open("dat/evo_#{sel}_#{mut}.dat", "w+")
      1000.times do |i|
        po.simple_ga(fun, sel, mut)
        #po.modified_ga(fun)
        #puts "fit: " + po.elite_selection(fun).fitness(fun).to_s
        file.write("#{i} #{po.average_fitness(fun)}\n")
      end
      file.close
      gpl_cmd += " 'evo_#{sel}_#{mut}.dat' w l,"
    end
    open("dat/#{sel}.gpl", "w+") {|f| f.write(gpl_cmd)}
  end
end

main()
