require "memq/version"
require "dalli"

module Memq
  class Queue
      
    attr_reader :client, :head, :tail

    def initialize(q = "default", server = "localhost:11211",params = {})
      @client = Dalli::Client.new(server,{:namespace => "queue_"}.merge(params))
      self.use q
    end
      
    def empty?(q = @q)
      raise "Queue '#{q}'' doesn't exist. Use 'rst' method to create." if !self.exists?(q)
      head,tail = @client.get("#{q}_head"), @client.get("#{q}_tail")
      if self.exists?(q) && (head.zero? && tail.zero? || (head == tail))
        return true
      end
      return false
    end

    def exists?(q = @q)
      @head = @client.get "#{q}_head"
      @tail = @client.get "#{q}_tail"
      if !@head.is_a?(Fixnum) || !@tail.is_a?(Fixnum) || @head.to_i > @tail.to_i
        return false
      end
      return true
    end    

    def rst(q = @q)
      @client.set "#{q}_head", 0 
      @client.set "#{q}_tail", 0
      @head,@tail = 0,0
      return true
    end
      
    def dequeue(r = 1,q = @q)
      return nil if self.empty?
      if r.is_a?(Fixnum)
        if (@tail+1) - (r + @head) > 0
          keys = (@head...(@head+r)).to_a
          @client.set "#{q}_head", @head+=r
          self.rst if @head == @tail
        else
          keys = (@head...@tail).to_a
          self.rst q
        end
        @client.get_multi keys.map{|e| "#{q}_#{e}" }
      else
        raise "Incorrect keynum" 
      end
    end
      
    def enqueue(v,q = @q)
      @client.set "#{q}_#{@tail}", v
      @client.set "#{q}_tail", @tail+=1
      @tail-1
    end
      
    def total(q = @q)
      @tail-@head
    end

    def use(q = nil)
      if !q.nil?
        self.rst q if !self.exists? q
        @q = q
        @head = @client.get "#{q}_head"
        @tail = @client.get "#{q}_tail"
      end
      [@q,@head,@tail]
    end

  end
end
