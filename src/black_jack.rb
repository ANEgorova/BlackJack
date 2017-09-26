#!/usr/bin/env ruby

# This is a BlackJack game
# Main function - start_game (you have to create table before)
# Card deck represented by array of 52 numbers from 1 to 52 ($deck)
# Before game this array generated
# $current_index - global index in card deck
# Cards get their natural value in Card::initialize (don't care about suit)
# User has 5 options: hit, stand, double_down, surrender, split
# After dealer reached 17 by the fastest way (ace = 11), game is finished
# See more documentation before classes and methods

# Class card describes one card for game
# value: Number cards - their natural value, jack, queen, king - 11-13; aces - 14
# view: how card represented (2-10, "J", "Q", "K", "A")
class Card
  attr_reader :view
  def initialize(idx)
    @view = get_view_by_index(idx)
  end

  def get_view_by_index(idx)
    value = idx / 4 + (idx % 4 == 0 ? 1 : 2)
    case
      when value <= 10
        return value.to_s
      when value == 11
        return 'J'
      when value == 12
        return 'Q'
      when value == 13
        return 'K'
      when value == 14
        return 'A'
    end
  end
end

# Class for all players in game (player or dealer)
# hand: array of cards' view
# money: current amount
# ace_score: alternative score for ace considered as 1
class User
  attr_accessor :hand, :money, :bet, :score, :has_ace, :ace_score
  def initialize
    @hand = Array.new
    @money = 1000
    @bet = 0
    @score = 0
    @has_ace = false
    @ace_score = 0
  end

  def first_init(is_player)
    @hand.clear
    @score = 0
    @has_ace = false
    @ace_score = 0
    for counter in 0..1
      add_new_card
      if counter == 0 or is_player
        update_score
      end
    end
  end

  def add_new_card
    new_card = Card.new($deck[$current_index])
    @hand << new_card.view
    $current_index += 1
  end

  def update_score
    card_value = @hand.last
    if card_value == 'A'
      @has_ace = true
      @ace_score = @ace_score + 1
      @score += 11
    else
      int_value = card_value.to_i
      case
        when int_value == 0
          @score += 10
          @ace_score += 10
        else
          @score += int_value
          @ace_score += int_value
      end
    end
  end

  def process_bet (bet)
    case bet
      when 1, 10
        @bet = 10
        @money -= 10
      when 2, 25
        @bet = 25
        @money -= 25
      when 3, 100
        @bet = 100
        @money -= 100
      when 4, 200
        @bet = 200
        @money -= 200
      when 5, 500
        @bet = 500
        @money -= 500
      else
        puts 'You entered wrong bet! Try again!'
        start_game
    end
    puts "You made #{@bet}$ bet!"
  end

  def update_money(is_winner, is_push)
    if is_push
      @money += @bet
    end
    if is_winner
      @money += (@bet * 2)
    end
    @bet = 0
    puts "Your money now is: #{@money}$"
  end

  def open_new_card
    add_new_card
    update_score
    puts '---------------'
    puts "New card is: #{@hand.last}"
    puts '---------------'
  end
end

# Class for game table
class Table
  attr_accessor :dealer, :player, :is_first_cards
  WINNER_SCORE = 21
  def initialize
    @dealer = User.new
    @player = User.new
    $current_index = 0
    @is_first_cards = true
  end

  def print_bet_choosing
    puts 'Make a bet: [1] 10$, [2] 25$, [3] 100$, [4] 200$, [5] 500$'
    puts 'Please, enter number or money amount without $ sign'
    gets.chomp.to_i
  end

  def first_init
    $deck = (1..52).to_a.sample 52
    @is_first_cards = true
    @player.first_init(true)
    @dealer.first_init(false)
  end

  def case_black_jack(player)
    puts 'You got 21!'
    puts "Dealer's second card:"
    @dealer.update_score
    @is_first_cards = false
    print_scores(player)
    if @dealer.score == 21
      puts 'PUSH! NOBODY WINS!'
      player.update_money(false, true)
    else
      puts 'BLACK JACK!'
      puts "You win #{player.bet}$"
      player.update_money(true, false)
    end
  end

  def print_scores(player)
    puts "Dealer: #{@is_first_cards ? (@dealer.hand.take 1) : @dealer.hand}; Score: #{@dealer.score}"
    puts "You: #{player.hand}; Score: #{player.score}#{player.has_ace ? '/' + (player.ace_score.to_s) :''}"
  end

  def print_options_choosing(player)
    options_string = 'Choose one option: [1]Hit [2]Stand'
    option_index = 3
    if player.hand.size == 2
      options_string += " [#{option_index}]Double_down [#{option_index + 1}]Surrender"
      option_index += 2
    end

    if player.hand[0] == player.hand[1]
      options_string += " [#{option_index}]Split"
    end
    puts options_string
    puts '(Print number or word)'
  end

  def get_diff(score)
    21 - score
  end

  def get_winner(player)
    if @dealer.score == player.score
      puts 'PUSH! NOBODY LOSE!'
      player.update_money(false, true)
    elsif @dealer.score > WINNER_SCORE
      puts 'YOU WIN! DEALER LOSE!'
      player.update_money(true, false)
    elsif get_diff(@dealer.score) < get_diff(player.score)
      puts 'YOU LOSE! DEALER WIN'
      player.update_money(false, false)
    else
      puts 'YOU WIN! DEALER LOSE!'
      player.update_money(true, false)
    end
  end

  # Method implements dealer game
  # Dealer reveal his second card and hit till his score < 17
  def dealer_game(player)
    @is_first_cards = false
    puts "Your score is #{player.score}!"
    puts "Dealer's turn:"
    @dealer.update_score
    self.print_scores(player)
    while @dealer.score. < 17
      sleep(1)
      @dealer.open_new_card
      puts "Your score: #{player.score}; Dealer score: #{@dealer.score}"
    end
    get_winner(player)
  end

  def play_again
    puts 'Do you want to play again? [y, Y, Yes, yes; n, N, No, no]'
    new_game_decision = gets.chomp
    if new_game_decision.match('y|Y|Yes')
      start_game
    else
      puts "Your money now is: #{@player.money}$"
      print 'Thanks for a game! Goodbye!'
      false
    end
  end

  def option_double_down(player)
    puts 'You increased your bet by 100%!'
    player.bet *= 2
    puts "Now your bet is: #{player.bet}"
    player.open_new_card
  end

  # Method implements Split options
  # Just process game for two hands by turn
  def option_split(player)
    player.hand.pop
    player.score /= 2
    player.ace_score /= 2
    split_player = player
    puts 'GAME FOR ONE HAND:'
    round(player)
    puts 'GAME FOR ANOTHER HAND:'
    round(split_player)
  end

  # Methods implements directly game
  # Choose option and change score and money
  def round(player)
    # if black jack from first 2 cards
    if player.score == 21
      case_black_jack(player)
      unless play_again
        return
      end
    end

    while true
      print_scores(player)
      if player.score == 21
        dealer_game(player)
        unless play_again
          break
        end
      end
      print_options_choosing(player)
      option = gets.chomp
      if option.match('1|Hit')
        player.open_new_card
        # if player got > 21 - game is over
        if player.score. > WINNER_SCORE
          if player.has_ace and player.ace_score < WINNER_SCORE
            player.score, player.ace_score = player.ace_score, player.score
          else
            puts "Your score is: #{player.score}"
            puts 'YOU LOSE! DEALER WIN'
            player.update_money(false, false)
            unless play_again
              break
            end
          end
        end
        next
      elsif option.match('2|Stand')
        dealer_game(player)
        unless play_again
          break
        end
      elsif option.match('3|Double_down')
        option_double_down(player)
        if player.score > WINNER_SCORE
          if player.has_ace and player.ace_score < WINNER_SCORE
            player.score = player.ace_score
            dealer_game(player)
          else
            puts "Your score is: #{player.score}"
            puts 'YOU LOSE! DEALER WIN'
            player.update_money(false, false)
          end
        end
        dealer_game(player)
        unless play_again
          break
        end
      elsif option.match('4|Surrender')
        puts "House returned #{player.bet}$ to you!"
        player.update_money(false, true)
        unless play_again
          break
        end
      elsif option.match('5|Split')
        option_split(player)
      else
        puts 'You entered wrong option! Try again!'
        next
      end
    end
  end
end

def start_game
  $game_table.first_init
  bet = $game_table.print_bet_choosing
  $game_table.player.process_bet(bet)
  $game_table.round($game_table.player)
end

puts 'Welcome to BlackJack!'
$game_table = Table.new
start_game