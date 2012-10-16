require "memq/version"
require "dalli"

module Memq
  class Memq
      
    attr_reader :mem

    def initialize(*params)
      @mem = Dalli.new("localhost:11211")
    end
      
    def isEmpty?(q)
      if !self.exists? q
        self.rst q
        return true
      elsif @head.zero? && @tail.zero? || (@head == @tail)
          return true
      end
      return false
    end

    def exists?(q)
      begin
        @head = @mem.get "#{q}_head"
        @tail = @mem.get "#{q}_tail"
      rescue Exception => e
        return false
      end
      if @head.is_a?(Fixnum) || @tail.is_a? (Fixnum) || @head > @tail
        return false
      end
      return true
    end    

    def rst(q)
      @mem.set q+"_head", 0 
      @mem.set q+"_tail", 0
      @head = @tail = 0 
      return true
    end
      
    def dequeue(q,r = 1)
      return nil if self.isEmpty? q
      if r.is_a(Fixnum)
        if (@tail+1) - (r + @head) > 0
          keys = (@head...(@head+r)).to_a
          @mem.set q+"_head", @head+=r
        else
          keys = (@head...@tail).to_a
          self.rst q
        end
        @mem.get keys.map{|e| "#{q}_#{e}" }
      else
        raise "Incorrect keynum" 
      end
    end
      
    def enqueue(q,v)
      self.rst q if !self.exists? q
      @mem.set q+"_tail", @tail+1
      @mem.set q+"_"+@tail.to_s, v
    end
      
    def total(q)
      if !self.exists? q
          self.rst q 
          return 0
      end
      @head = mem.get q+"_head"
      @tail = mem.get q+"_tail"
      (@tail-@head)
    end

  end
end
