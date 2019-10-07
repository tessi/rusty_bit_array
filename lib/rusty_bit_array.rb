require "rusty_bit_array/version"
require 'rutie'

module RustyBitArray
  class Error < StandardError; end
  
  Rutie.new(:rusty_bit_array).init 'Init_bit_array', __dir__
end
