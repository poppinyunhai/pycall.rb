require 'pycall/import'
include PyCall::Import

require 'benchmark'
pyimport :pandas, as: :pd
pyimport :seaborn, as: :sns
pyimport 'matplotlib.pyplot', as: :plt

array = Array.new(100_000) { rand }

trials = 100
results = { method: [], runtime: [] }

# Array#sum
trials.times do
  results[:method] << 'sum'
  results[:runtime] << Benchmark.realtime { array.sum }
end

# Array#inject(:+)
trials.times do
  results[:method] << 'inject'
  results[:runtime] << Benchmark.realtime { array.inject(:+) }
end

# while
def while_sum(ary)
  sum, i, n = 0, 0, ary.length
  while i < n
    sum += ary[i]
    i += 1
  end
  sum
end

trials.times do
  results[:method] << 'while'
  results[:runtime] << Benchmark.realtime { while_sum(array) }
end

# visualization

df = pd.DataFrame.(PyCall::Dict.new(results))
sns.barplot.(x: 'method', y: 'runtime', data: df)
plt.title.("Array summation benchmark (#{trials} trials)")
plt.xlabel.('Summation method')
plt.ylabel.('Average runtime [sec]')
plt.show.()
