# encoding: utf-8

require "socket"
require 'json'

class Client
  def initialize(options = {})
    defaults = {
      ip: 'localhost',
      port: 2500
    }
    options = defaults.merge(options)
    
    @ip = options[:ip]
    @port = options[:port]
    
    @messages = []
  end
  
  def play
    server = TCPSocket.new(@ip, @port)
    
    puts "Waiting for opponent..."
    
    loop do
      message = JSON.parse(server.gets) 
      
      case message['type']
      when "game over"
        break
      when "line"
        puts message["body"]
      when "board"
        puts message["body"]
        puts
      when "prompt"
        print message["body"]
        server.puts get_move
      when "error"
        puts message["body"]
      else
        puts "Bad data"
      end
    end   
  end
  
  def get_move
    gets.strip
  end
end

if __FILE__ == $PROGRAM_NAME
  client = Client.new
  client.play
end