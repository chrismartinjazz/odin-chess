module Greetings
  @name2 = 'Jill'

  def hello
    puts "Hello, #{@name1}!"
    goodbye
  end
end

class Conversation
  include Greetings

  def initialize
    @name1 = 'Jack'
  end

  def say_hello
    hello
  end

  def goodbye
    puts "Goodbye, #{@name2}."
  end
end

Conversation.new.say_hello
