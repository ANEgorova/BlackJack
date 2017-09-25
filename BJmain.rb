#!/usr/bin/env ruby

# Documentation: HARD OR SOFT 17 (stand anyway)
$winner_score = 21
$is_first_cards = true
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
  player['has_ace'] = false
  player['ace_score'] = 0
  player['cards'] = Array.new
  player['hand'] = Array.new
  for counter in 0..1
    new_card = get_card_by_index($cards_indexes[$current_index])
    player['cards'] << new_card
    player['hand'] << prettify_card(new_card)
    $current_index += 1
    if counter == 0 or is_user
      update_score(player, player['cards'].last, new_card == 14)
    end
  end
end

def print_scores(user)
  puts "Dealer: #{$is_first_cards ? ($dealer['hand'].take 1) : $dealer['hand']}; Score: #{$dealer['score']}"
  puts "You: #{user['hand']}; Score: #{user['score']}#{user['has_ace'] ? '/' + (user['ace_score'].to_s) :''}"
end

def print_options_choosing(user)
  options_string = 'Choose one option: [1]Hit [2]Stand'
  option_index = 3
  if user['cards'].size == 2
    options_string += " [#{option_index}]Double_down [#{option_index + 1}]Surrender"
    option_index += 2
  end

  if user['hand'][0] == user['hand'][1]
    options_string += " [#{option_index}]Split"
  end
  puts options_string
  puts '(Print number or word)'
end

def add_new_card(player)
  new_card = get_card_by_index($cards_indexes[$current_index])
  player['cards'] << new_card
  player['hand'] << prettify_card(new_card)
  update_score(player, new_card, new_card == 14)
  $current_index += 1
  puts '---------------'
  puts "New card is: #{player['hand'].last}"
  puts '---------------'
end

def update_score(player, card, is_ace)
  if is_ace
    player['has_ace'] = true
    player['ace_score'] = player['score'] + 1
    player['score'] += 11
  else
    player['score'] += card < 10 ? card : 10
    player['ace_score'] += card < 10 ? card : 10
  end
end

def get_diff(player)
  return 21 - player['score']
end

def init_table
  $current_index = 0
  $is_first_cards = true
  $cards_indexes = get_cards_indexes
  init_state($user, true)
  init_state($dealer,false)
  $user['bet'] = 0
end

def get_winner(user)
  if $dealer['score'] == user['score']
    puts 'PUSH! NOBODY LOSE!'
    update_money(user, false, true)
  elsif $dealer['score'] > 21
    puts 'YOU WIN! DEALER LOSE!'
    update_money(user, true, false)
  elsif get_diff($dealer) < get_diff(user)
    puts 'YOU LOSE! DEALER WIN'
    update_money(user, false, false)
  else
    puts 'YOU WIN! DEALER LOSE!'
    update_money(user, true, false)
  end
end

def dealer_game(user)
  $is_first_cards = false
  puts "Your score is #{user['score']}!"
  puts "Dealer's turn:"
  update_score($dealer, $dealer['cards'][1], false)
  print_scores(user)
  while $dealer['score'] < 17
    sleep(1)
    add_new_card($dealer)
    puts "Your score: #{user['score']}; Dealer score: #{$dealer['score']}"
  end
  get_winner(user)
end

def play_again
  puts 'Do you want to play again? [y, Y, Yes, yes; n, N, No, no]'
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

def case_black_jack(user)
  puts 'You got 21!'
  puts "Dealer's second card:"
  update_score($dealer, $dealer['cards'][1], false)
  $is_first_cards = false
  print_scores(user)
  if $dealer['score'] == 21
    puts 'PUSH! NOBODY WINS!'
    update_money(user, false, true)
  else
    puts 'BLACK JACK!'
    puts "You win #{$user['bet']}$"
    update_money(user, true, false)
  end
end

def option_double_down(user)
  puts 'You increased your bet by 100%!'
  user['bet'] *= 2
  puts "Now your bet is: #{user['bet']}"
  add_new_card(user)
end

def option_split(user)
  user['cards'].pop
  user['hand'].pop
  user['score'] /= 2
  user['ace_score'] /= 2
  split_user = user
  puts 'GAME FOR ONE HAND:'
  game(user)
  puts 'GAME FOR ANOTHER HAND:'
  game(split_user)
end

def game(user)
  if user['score'] == 21
    case_black_jack(user)
    unless play_again
      return
    end
  end
  while true
    print_scores(user)
    if user['score'] == 21
      dealer_game(user)
      unless play_again
        break
      end
    end
    print_options_choosing(user)
    option = gets.chomp
    if option.match('1|Hit')
      add_new_card(user)
      if user['score'] > $winner_score
        if user['has_ace'] and user['ace_score'] < 21
          user['score'], user['ace_score'] = user['ace_score'], user['score']
          next
        else
          puts "Your score is: #{user['score']}"
          puts 'YOU LOSE! DEALER WIN'
          update_money(user, false, false)
          unless play_again
            break
          end
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
      option_double_down(user)
      if user['score'] > $winner_score
        puts "Your score is: #{user['score']}"
        puts 'YOU LOSE! DEALER WIN'
        update_money(user, false, false)
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
      puts "House returned #{user['bet']}$ to you!"
      update_money(user, false, true)
      unless play_again
        break
      end
    elsif option.match('5|Split')
      option_split(user)
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