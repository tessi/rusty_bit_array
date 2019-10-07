RSpec.describe RustyBitArray do
  it "has a version number" do
    expect(RustyBitArray::VERSION).not_to be nil
  end

  describe "initializing the array" do
    it "initializes all values with false" do
      bit_array = RustyBitArray::BitArray.new(10)
      (0...10).each do |i|
        expect(bit_array[i]).to be false
      end
    end

    it 'can initialize with 0 size' do
      expect(RustyBitArray::BitArray.new(0).length).to be 0
    end

    it 'throws an ArgumentError with negative size' do
      expect {
        RustyBitArray::BitArray.new(-5)
      }.to raise_error(ArgumentError)
    end

    it 'throws a TypeError when creating with non-numbers' do
      expect {
        RustyBitArray::BitArray.new("not a number")
      }.to raise_error(TypeError)
    end
  end

  describe "acessing values" do
    it 'returns nil when accessing out of bounds' do
      expect(RustyBitArray::BitArray.new(1)[1]).to be nil
    end

    it 'allows access with negative numbers' do
      bit_array = RustyBitArray::BitArray.new(4)
      expect(bit_array[-1]).to be false
    end

    it 'returns nil when backwards accessing out of bounds' do
      expect(RustyBitArray::BitArray.new(1)[-2]).to be nil
    end

    it 'throws a TypeError when given a non-number as key' do
      bit_array = RustyBitArray::BitArray.new(4)
      expect {bit_array["foo"]}.to raise_error(TypeError)
      expect {bit_array[3.14]}.to raise_error(TypeError)
      expect {bit_array[:foo]}.to raise_error(TypeError)
    end
  end

  describe "writing values" do
    it 'can set a thruthy/falsy value and read it back out as boolean' do
      bit_array = RustyBitArray::BitArray.new(8)
      bit_array[0] = nil
      expect(bit_array[0]).to be false
      expect(bit_array[-8]).to be false

      bit_array[1] = false
      expect(bit_array[1]).to be false
      expect(bit_array[-7]).to be false

      bit_array[2] = true
      expect(bit_array[2]).to be true
      expect(bit_array[-6]).to be true

      bit_array[3] = "test"
      expect(bit_array[3]).to be true
      expect(bit_array[-5]).to be true

      bit_array[4] = 4
      expect(bit_array[4]).to be true
      expect(bit_array[-4]).to be true

      bit_array[5] = 0
      expect(bit_array[5]).to be true
      expect(bit_array[-3]).to be true

      bit_array[6] = :symbol
      expect(bit_array[6]).to be true
      expect(bit_array[-2]).to be true

      bit_array[7] = [1,2,3]
      expect(bit_array[7]).to be true
      expect(bit_array[-1]).to be true
    end

    it 'allows indexing with negative numbers' do
      bit_array = RustyBitArray::BitArray.new(4)
      bit_array[-1] = true # writes at index 3
      expect(bit_array[3]).to be true
    end

    it 'throws IndexError when indexing out of bounds' do
      bit_array = RustyBitArray::BitArray.new(1)
      expect { bit_array[1] = true }.to raise_error(IndexError)
    end

    it 'throws an IndexError when backwards indexing out of bounds' do
      bit_array = RustyBitArray::BitArray.new(1)
      expect { bit_array[-2] = true }.to raise_error(IndexError)
    end

    it 'throws a TypeError when given a non-number as key' do
      bit_array = RustyBitArray::BitArray.new(4)
      expect { bit_array["foo"] = true }.to raise_error(TypeError)
      expect { bit_array[3.14]  = true }.to raise_error(TypeError)
      expect { bit_array[:foo]  = true }.to raise_error(TypeError)
    end
  end

  describe "getting the length/size of the array" do
    it "returns the size on length()" do
      bit_array = RustyBitArray::BitArray.new(4)
      expect(bit_array.length).to be 4
    end

    it "returns the size on size()" do
      bit_array = RustyBitArray::BitArray.new(55)
      expect(bit_array.size).to be 55
    end
  end
end
