#!/usr/bin/env ruby

$winner_score = 21
$is_first = true
$current_index = 0
$cards_indexes = Array.new
$user = Hash.new
$dealer = Hash.new
$user['money'] = 1000

def get_cards_indexes
  return (1..52).to_a.sample 52
end

def get_card_by_index(idx)
  return idx / 4 + (idx % 4 == 0 ? 1 : 2)
end

def prettify_card(card_number)
  case
    when card_number <= 10
      return card_number.to_s
    when card_number == 11
      return 'J'
    when card_number == 12
      return 'Q'
    when card_number == 13
      return 'K'
    when card_number == 14
      return 'A'
  end
end

def init_state(player, is_user)
  player['score'] = 0
  cards = Array.new
  hand = Array.new
  # TODO: Loop
  cards << get_card_by_index($cards_indexes[$current_index])
  hand << prettify_card(cards.last)
  update_score(player, cards.last)
  $current_index += 1
  cards << get_card_by_index($cards_indexes[$current_index])
  hand << prettify_card(cards.last)
  if is_user
    update_score(player, cards.last)
  end
  $current_index += 1
  player['cards'] = cards
  player['hand'] = hand
end

def print_scores
  if $is_first
    puts "Dealer: #{$dealer['hand'].take 1}; Score: #{$dealer['score']}"
  else
    puts "Dealer: #{$dealer['hand']}; Score: #{$dealer['score']}"
  end
  puts "You: #{$user['hand']}; Score: #{$user['score']}"
end

def print_options_choosing
  options_string = 'Choose one option: [1]Hit [2]Stand'
  option_index = 3
  if $user['cards'].size == 2
    options_string += " [#{option_index}]Double_down [#{option_index + 1}]Surrender"
    option_index += 2
  end

  if $user['hand'][0] == $user['hand'][1]
    options_string += " [#{option_index}]Split"
  end
  puts options_string
  puts '(Print number or word)'
end

def add_new_card(player)
  # TODO: one function for adding new card
  new_card = get_card_by_index($cards_indexes[$current_index])
  player['cards'] << new_card
  player['hand'] << prettify_card(new_card)
  update_score(player, new_card)
  $current_index += 1
  puts '---------------'
  puts "New card is: #{prettify_card(new_card)}"
  puts '---------------'
end

def update_score(player, card)
  player['score'] += card < 10 ? card : 10
end

def get_user_diff
  # do you need abs??
  return (21 - $user['score']).abs
end

def get_dealer_diff
  return (21 - $dealer['score']).abs
end

def init_table
  $current_index = 0
  $is_first = true
  $cards_indexes = get_cards_indexes
  init_state($user, true)
  init_state($dealer,false)
  $user['bet'] = 0
end

def get_winner(user)
  if $dealer['score'] == user['score']
    puts 'Push! NOBODY LOSE!'
    update_money(user, false, true)
  elsif $dealer['score'] > 21
    puts 'YOU WIN! DEALER LOSE!' # print score????
    update_money(user, true, false)
  elsif get_dealer_diff < get_user_diff
    puts 'YOU LOSE! DEALER WIN'
    update_money(user, false, false)
  else
    puts 'YOU WIN! DEALER LOSE!'
    update_money(user, true, false)
  end
end

def dealer_game(user)
  $is_first = false
  puts "Your score is #{user['score']}!"
  puts "Dealer's turn:"
  update_score($dealer, $dealer['cards'][1])
  print_scores
  while $dealer['score'] < 17
    sleep(1)
    add_new_card($dealer)
    puts "Your score: #{user['score']}; Dealer score: #{$dealer['score']}"
  end
  get_winner(user)
end

def play_again
  puts 'Do you want to play again? ([Y]es/[N]o)'
  new_game_decision = gets.chomp
  if new_game_decision.match('y|Y|Yes')
    main
  else
    puts "Your money now is: #{$user['money']}$"
    print 'Thanks for a game! Goodbye!'
    return false
  end
end

def process_bet (player, bet)
  case bet
    when 1
      player['bet'] = 10
      player['money'] -= 10
    when 2
      player['bet'] = 25
      player['money'] -= 25
    when 3
      player['bet'] = 100
      player['money'] -= 100
    when 4
      player['bet'] = 200
      player['money'] -= 200
    when 5
      player['bet'] = 500
      player['money'] -= 500
    else
      player['bet'] = bet
      player['money'] -= bet
  end
  puts "You made #{player['bet']}$ bet!"
end

def update_money(player, is_winner, is_push)
  if is_push
    player['money'] += $user['bet']
  end
  if is_winner
    player['money'] += ($user['bet'] * 2)
  end
  player['bet'] = 0
  puts "Your money now is: #{player['money']}$"
end

def print_bet_choosing
  puts 'Make a bet: [1] 10$, [2] 25$, [3] 100$, [4] 200$, [5] 500$'
  puts 'Please, enter number or money amount without $ sign'
  return gets.chomp.to_i
end

def game(user)
  if user['score'] == 21
    puts 'You got 21!'
    puts "Dealer's second card:"
    update_score($dealer, $dealer['cards'][1])
    $is_first = false
    print_scores
    if $dealer['score'] == 21
      puts 'PUSH! NOBODY WINS!'
      update_money(user, false, true)
    else
      puts 'BLACK JACK!'
      puts "You win #{$user['bet']}"
      update_money(user, true, false)
    end
    unless play_again
      return
    end
  end
  while true
    print_scores
    if user['score'] == 21
      dealer_game(user)
      unless play_again
        break
      end
    end
    print_options_choosing
    option = gets.chomp
    if option.match('1|Hit')
      add_new_card(user)
      if user['score'] > $winner_score
        puts "Your score is: #{user['score']}"
        puts 'YOU LOSE! DEALER WIN'
        update_money(user, false, false)
        unless play_again
          break
        end
      else
        next
      end
    elsif option.match('2|Stand')
      dealer_game(user)
      unless play_again
        break
      end
    elsif option.match('3|Double_down')
      # put into function double_down game
      puts 'You increased your bet by 100%!'
      puts 'Now your money is: 0'
      add_new_card(user)
      if user['score'] > $winner_score
        puts "Your score is: #{user['score']}"
        puts 'YOU LOSE! DEALER WIN'
        unless play_again
          break
        end
      else
        dealer_game(user)
        unless play_again
          break
        end
      end
    elsif option.match('4|Surrender')
      puts 'House returned HOW MUCH to you!'
      unless play_again
        break
      end
    elsif option.match('5|Split')
      split_user = Hash.new
      split_user['cards'] << user['cards'].pop
      split_user['hand'] << user['hand'].pop
      split_user['score'] = 0
      update_score(split_user, split_user['cards'][0])
      user['score'] = 0
      update_score(user, user['cards'][0])
      puts 'GAME FOR ONE HAND:'
      game(user)

      puts 'GAME FOR ANOTHER HAND:'
      game(split_user)
    else
      puts 'You entered wrong option! Try again!'
      next
    end
  end
end

def main
  init_table
  bet = print_bet_choosing
  process_bet($user, bet)
  game($user)
end

puts 'Welcome to BlackJack'
puts 'Your money now is 1000$'
main