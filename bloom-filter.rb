# Bloom filter, conceived by Burton Howard Bloom in 1970,
# is a space-efficient probabilistic data structure that is used to test whether an element is a member of a set.
# False positive retrieval results are possible, but false negatives are not.
# Elements can be added to the set, but not removed (though this can be addressed with a counting filter).
# The more elements that are added to the set, the larger the probability of false positives.

# m - bit array size
# n - number of elements
# k - number of hash functions
# p - error probability

class BloomFilter
  def initialize m, k
    @size = m
    @bits = 2 ** (m + 1)
    k.times { (@hashes ||= [])  << create_hash }
  end

  def set_bit pos
    @bits |= 1 << (pos - 1)
  end

  def get_bit pos
    @bits >> (pos - 1) & 1
  end

  def create_hash
    seed = (rand * 32).floor + 32

    Proc.new do |x|
      res = 1
      x.to_s.each_byte do |byte|
        res = (seed * res + byte) & 0xFFFFFFFF
      end
      res
    end
  end

  def add element
    @hashes.each do |h|
      pos = h.call(element) % @size
      set_bit pos.to_i
    end
  end

  def contains? element
    @hashes.each do |h|
      pos = h.call(element) % @size
      return false if get_bit(pos.to_i).zero?
    end
    true
  end

  def to_s
    @bits.to_s(2)
  end

  def size
    @size
  end

  alias_method :bits, :to_s
end

class OptimalBloomFilter < BloomFilter
  def initialize n, p
    m = -(n * Math.log(p)) / (Math.log(2) ** 2)
    k = m / n * Math.log(2)

    super m.round, k.round
  end
end

b = BloomFilter.new 64, 2
b.add('alpha')
b.add('betta')
alpha = b.contains?('alpha')
gamma = b.contains?('gamma')
betta = b.contains?('betta')

ob = OptimalBloomFilter.new 3, 0.01
ob.add('one')
ob.add('two')
one = ob.contains?('one')
three = ob.contains?('three')
two = ob.contains?('two')
