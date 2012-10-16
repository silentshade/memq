# Memq

Memq is a lightweight simple queue solution, based on Memcached and Dalli. It's a port of this https://github.com/abhinavsingh/memq.git PHP MEMQ class, with some minor changes.

## Installation

Add this line to your application's Gemfile:

    gem 'memq'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install memq

Memq will attempt to install latest version of dalli gem automaticly.

## Usage

```ruby
require 'memq'

mem = Memq::Queue.new
```
Above code will initialize Queue object and attempt to create a default queue with a key "default".

If you wish, you can pass some dalli options, and a queue key name:

```ruby
mem = Memq::Queue.new "mail", "localhost:11211", {:compress => true}
```
Enqueue something. The method will return queue position..
```ruby
mem.enqueue "Hello world!" # => 0 
mem.enqueue "Aloha world!" # => 1
mem.total                  # => 2
```
Call mem.total to see queue length

Dequeue.
```ruby
mem.dequeue                #  => {"mail_0"=>"Hello world!"} 
```
The keys are "queuename_position"

Enqueue some more
```ruby
mem.enqueue [1,2,3,4,5]                            # => 2 
mem.enqueue({:hello => 'word', :aloha => 'world'}) # => 3
mem.total                                          # => 3
```

Dequeue all in a row
```ruby
mem.dequeue mem.total
# => {"mail_1"=>"Aloha world!", "mail_2"=>[1, 2, 3, 4, 5], "mail_3"=>{:hello=>"word", :aloha=>"world"}}
mem.total    # => 0
```
Please keep in mind that dequeing currently doesn't actually delete your queued items. 
It only ajusts queue head and tail pointers. So, you can access an already dequeued item directly:
```ruby
mem.client.get "mail_0"   # => "Hello world!"
```
mem.client is just a Dalli client instance, so it can do everything Dalli client can.

By default the queue is named "default". You can create and manipulate other queues by single object instance:
```ruby
mem.use "process"  # => ["process", 0, 0]
```
will create "process" queue if it doesn't exist and switch using it. The method returns an array with queue name, 
head and tail pointer values. If called without arguments, it will return this array for current queue.

Also you can reset your queue, check if queue exists and if queue is empty:
```ruby
mem.rst       # => true
mem.exists?   # => true
mem.empty?    # => true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
