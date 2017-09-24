#!/usr/bin/env ruby

$winner_score = 21
$is_first = true
$current_index = 0
$cards_indexes = Array.new
$user = Hash.new
$dealer = Hash.new

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

def print_scores(is_first)
  if $is_first
    puts "Dealer: #{$dealer['hand'].take 1}; Score: #{$dealer['score']}"
  else
    puts "Dealer: #{$dealer['hand']}; Score: #{$dealer['score']}"
  end
  puts "You: #{$user['hand']}; Score: #{$user['score']}"
  if $is_first

  end
end

def print_options_choosing
  puts 'Choose one option: [1]Hit [2]Stand'
  puts '(Print number or word)'
end

def add_new_card(player)
  # TODO: one function for adding new card
  new_card = get_card_by_index($cards_indexes[$current_index])
  player['cards'] << new_card
  player['hand'] << prettify_card(new_card)
  update_sum(player, new_card)
  $current_index += 1
  puts "New card is: #{new_card}"
end

def update_sum(player, card)
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
end

def get_winner
  if $dealer['score'] == $user['score']
    puts 'Push! NOBODY LOSE!'
  elsif $dealer['score'] > 21
    puts 'YOU WIN! DEALER LOSE!' # print score????
  elsif get_dealer_diff < get_user_diff
    puts 'YOU LOSE! DEALER WIN'
  else
    puts 'YOU WIN! DEALER LOSE!'
  end
end

def dealer_game
  $is_first = false
  puts "Your score is #{$user['score']}!"
  puts "Dealer's turn:"
  update_sum($dealer, $dealer['cards'][1])
  print_scores($is_first)

  while $dealer['score'] < 17
    add_new_card($dealer)
    puts "Your score: #{$user['score']}; Dealer score: #{$dealer['score']}"
  end

  get_winner
end

def play_again
  puts 'Do you want to play again? ([Y]es/[N]o)'
  new_game_decision = gets.chomp
  if new_game_decision.match('y|Y|Yes')
    init_table
    game
  else
    puts 'You money: 0'
    print 'Goodbye!'
    return false
  end
end

def game
  # TODO: Check BlackJack
  while true
    print_scores($is_first)
    if $user['score'] == 21
      dealer_game
      unless play_again
        break
      end
    end
    print_options_choosing
    option = gets.chomp
    if option.match('1|Hit')
      add_new_card($user)
      if $user['score'] > $winner_score
        puts "Your score is: #{$user['score']}"
        puts 'YOU LOSE! DEALER WIN'
        unless play_again
          break
        end
      else
        next
      end
    elsif option.match('2|Stand')
      dealer_game
      unless play_again
        break
      end
    end
  end
end

init_table
game