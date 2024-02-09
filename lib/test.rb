module Greetings
  @name2 = 'Jill'

  def hello
    puts "Hello, #{@name1}!"
    goodbye
  end
end

class Conversation
  include Greetings
  name3 = 'James'

  def initialize
    @name1 = 'Jack'
  end

  def say_hello
    hello
  end

  def goodbye
    puts "Goodbye, #{@name2}."
    puts "Goodbye, #{name3}."
  end
end

Conversation.new.say_hello
