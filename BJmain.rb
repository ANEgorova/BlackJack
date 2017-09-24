#!/usr/bin/env ruby

$winner_number = 21
$is_first = true
$current_index = 0
$cards_indexes = Array.new
$user = Hash.new
$dealer = Hash.new

def get_cards_indexes
  # TODO: DEAL WITH QUEEN, KING AND SO ON
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
    when card_number == 12
      return 'A'
  end
end

def init_state(player, is_user)
  player['sum'] = 0
  cards = Array.new
  hand = Array.new
  # TODO: Loop
  cards << get_card_by_index($cards_indexes[$current_index])
  hand << prettify_card(cards.last)
  update_sum(player, cards.last)
  $current_index += 1
  cards << get_card_by_index($cards_indexes[$current_index])
  hand << prettify_card(cards.last)
  if is_user
    update_sum(player, cards.last)
  end
  $current_index += 1
  player['cards'] = cards
  player['hand'] = hand
end

def print_state(is_first)
  if $is_first
    puts "Dealer: #{$dealer['hand'][0]}; Sum: #{$dealer['sum']}"
  else
    puts "Dealer: #{$dealer['hand']}; Sum: #{$dealer['sum']}"
  end
  puts "You: #{$user['hand']}; Sum: #{$user['sum']}"
  if $is_first
    puts 'Choose one option: [1]Hit [2]Stand'
    puts 'Example: 1 or Hit'
  end
end

def print_new_card(player)
  new_card = get_card_by_index($cards_indexes[$current_index])
  $current_index += 1
  puts new_card
  player['cards'] << new_card
  update_sum(player, new_card)
end

def update_sum(player, card)
  player['sum'] += card < 10 ? card : 10
end

def get_user_diff
  return (21 - $user['sum']).abs
end

def get_dealer_diff
  return (21 - $dealer['sum']).abs
end

def init_table
  $cards_indexes = get_cards_indexes
  $current_index = 0
  init_state($user, true)
  init_state($dealer,false)
end

#TODO: sum -> score
def get_winner
  if $dealer['sum'] == $user['sum']
    puts 'Push! NOBODY LOSE!'
  elsif $dealer['sum'] > 21
    puts 'YOU WIN! DEALER LOSE!' # print score????
  elsif get_dealer_diff < get_user_diff
    puts 'YOU LOSE! DEALER WIN'
  else
    puts 'YOU WIN! DEALER LOSE!'
  end
end

def dealer_game
  $is_first = false
  puts "Your score is #{$user['sum']}!"
  puts "Dealer's turn:"
  update_sum($dealer, $dealer['cards'][1])
  print_state($is_first)

  while $dealer['sum'] < 17
    print_new_card($dealer)
    puts "Your score: #{$user['sum']}; Dealer score: #{$dealer['sum']}"
  end

  get_winner
end

def play_again
  puts 'Do you want to play again? ([Y]es/[N]o)'
  return gets.chomp
end

def game
  # TODO: Check BlackJack
  while true
    print_state($is_first)
    if $user['sum'] == 21
      dealer_game
      if play_again.match('Y|Yes')
        init_table
      else
        puts 'You money: 0'
        puts 'Goodbye!'
        break
      end
    end
    option = gets.chomp
    if option.match('1|Hit')
      print_new_card($user)
      if $user['sum'] > $winner_number
        puts "Your score is: #{$user['sum']}"
        puts 'YOU LOSE! DEALER WIN'
        break
      else
        next
      end
    elsif option.match('2|Stand')
      dealer_game
      if play_again.match('Y|Yes')
        init_table
      else
        puts 'You money: 0'
        puts 'Goodbye!'
        break
      end
    end
  end
end

init_table
game