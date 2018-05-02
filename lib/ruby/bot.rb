require 'telegram/bot'

include ErlPort::Erlang

def register_handler(token, dest)
  puts "register_handler!!!!!!!!!!!!!!!!"
  set_message_handler {|message|
    p "ruby recieve message"
    p message[1]
    send_message_to_user(token, JSON.parse(message[1]))
  }
  ErlPort::Erlang::self()
end

def run_bot(supervisor_pid, token, ex_module=nil)
  p 'run_bot!!!!!!'
  Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
      puts "telegram receive message"
      puts message.inspect
      send_message_to_supervisor(supervisor_pid, message)
    end
  end
end

def send_message_to_supervisor(supervisor_pid, message)
  p parsed_message = {
      user: {
          id: message.from.id,
          is_bot: message.from.is_bot,
          first_name:  message.from.first_name,
          last_name: message.from.last_name,
          username:  message.from.username
      },
      chat: {
          id: message.chat.id,
          type: message.chat.type
      },
      text: message.text,
      date: message.date
  }
  p ErlPort::Erlang::cast(supervisor_pid, Tuple.new([:message, JSON.dump(parsed_message)]))
end

def send_message_to_user(token, message)
  Telegram::Bot::Client.run(token) do |bot|
    bot.api.send_message(chat_id: message["chat"]["id"], text: message["text"])
  end
end