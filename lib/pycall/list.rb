module PyCall
  class List
    def self.new(init=nil)
      case init
      when PyObject
        super
      when nil
        new(0)
      when Integer
        new(LibPython.PyList_New(init))
      when Array
        new.tap do |list|
          init.each do |item|
            list << item
          end
        end
      else
        new(obj.to_ary)
      end
    end

    def initialize(pyobj)
      check_type pyobj
      @__pyobj__ = pyobj
    end

    attr_reader :__pyobj__

    def ==(other)
      case other
      when List
        __pyobj__ == other.__pyobj__
      else
        super
      end
    end

    def [](index)
      LibPython.PyList_GetItem(__pyobj__, index).to_ruby
    end

    def []=(index, value)
      value = Conversions.from_ruby(value)
      LibPython.PyList_SetItem(__pyobj__, index, value)
      value
    end

    def <<(value)
      value = Conversions.from_ruby(value)
      LibPython.PyList_Append(__pyobj__, value)
      self
    end

    def size
      LibPython.PyList_Size(__pyobj__)
    end

    def include?(value)
      value = Conversions.from_ruby(value)
      LibPython.PyList_Contains(__pyobj__, value).to_ruby
    end

    def to_a
      [].tap do |a|
        i, n = 0, size
        while i < n
          a << self[i]
          i += 1
        end
      end
    end

    alias to_ary to_a

    private

    def check_type(pyobj)
      return if pyobj.kind_of?(PyObject) && pyobj.kind_of?(LibPython.PyList_Type)
      raise TypeError, "the argument must be a PyObject of list"
    end
  end
end
