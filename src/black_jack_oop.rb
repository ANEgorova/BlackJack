#!/usr/bin/env ruby

class Card
  attr_reader :value, :view
  def initialize(idx)
    @value = idx / 4 + (idx % 4 == 0 ? 1 : 2)
    @view = get_view_by_value(@value)
  end

  def get_view_by_value(value)
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

class User
  attr_accessor :cards, :hand, :money, :bet, :score, :has_ace, :ace_score
  def initialize
    @cards = Array.new
    @hand = Array.new
    @money = 1000
    @bet = 0
    @score = 0
    @has_ace = false
    @ace_score = 0
  end

  def first_init(is_player)
    @cards.clear
    @hand.clear
    @score = 0
    @has_ace = false
    @ace_score = 0
    for counter in 0..1
      add_new_card
      if counter == 0 or is_player
        self.update_score
      end
    end
  end

  def add_new_card
    new_card = Card.new($cards[$current_index])
    @cards << new_card.value
    @hand << new_card.view
    $current_index += 1
  end

  def update_score
    card_value = @cards.last
    if card_value == 14
      @has_ace = true
      @ace_score = @score + 1
      @score += 11
    else
      @score += card_value < 10 ? card_value : 10
      @ace_score += card_value < 10 ? card_value : 10
    end
  end

  def process_bet (bet)
    case bet
      when 1
        @bet = 10
        @money -= 10
      when 2
        @bet = 25
        @money -= 25
      when 3
        @bet = 100
        @money -= 100
      when 4
        @bet = 200
        @money -= 200
      when 5
        @bet = 500
        @money -= 500
      else
        @bet = bet
        @money -= bet
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
    self.add_new_card
    self.update_score
    puts '---------------'
    puts "New card is: #{@hand.last}"
    puts '---------------'
  end
end

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
    $cards = (1..52).to_a.sample 52
    @is_first_cards = true
    @player.first_init(true)
    @dealer.first_init(false)
  end

  def case_black_jack(player)
    puts 'You got 21!'
    puts "Dealer's second card:"
    @dealer.update_score
    @is_first_cards = false
    self.print_scores(player)
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
    if player.cards.size == 2
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
    return 21 - score
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
      first_init
      bet = print_bet_choosing
      @player.process_bet(bet)
    else
      puts "Your money now is: #{@player.money}$"
      print 'Thanks for a game! Goodbye!'
      return false
    end
  end

  def option_double_down(player)
    puts 'You increased your bet by 100%!'
    player.bet *= 2
    puts "Now your bet is: #{player.bet}"
    player.open_new_card
  end

  def option_split(player)
    player.cards.pop
    player.hand.pop
    player.score /= 2
    player.ace_score /= 2
    split_player = player
    puts 'GAME FOR ONE HAND:'
    game(player)
    puts 'GAME FOR ANOTHER HAND:'
    game(split_player)
  end

  # TODO: parameters (user -> player)
  def game(player)
    if player.score == 21
      self.case_black_jack(player)
      unless self.play_again
        return
      end
    end
    while true
      self.print_scores(player)
      if player.score == 21
        self.dealer_game(player)
        unless self.play_again
          break
        end
      end
      print_options_choosing(player)
      option = gets.chomp
      if option.match('1|Hit')
        player.open_new_card
        if player.score. > WINNER_SCORE
          if player.has_ace and player.ace_score < WINNER_SCORE
            player.score, player.ace_score = player.ace_score, player.score
            next
          else
            puts "Your score is: #{player.score}"
            puts 'YOU LOSE! DEALER WIN'
            player.update_money(false, false)
            unless self.play_again
              break
            end
          end
        else
          next
        end
      elsif option.match('2|Stand')
        self.dealer_game(player)
        unless self.play_again
          break
        end
      elsif option.match('3|Double_down')
        option_double_down(player)
        if player.score > WINNER_SCORE
          puts "Your score is: #{player.score}"
          puts 'YOU LOSE! DEALER WIN'
          player.update_money(false, false)
          unless self.play_again
            break
          end
        else
          self.dealer_game(player)
          unless self.play_again
            break
          end
        end
      elsif option.match('4|Surrender')
        puts "House returned #{player.bet}$ to you!"
        player.update_money(false, true)
        unless self.play_again
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

def main
  game_table = Table.new
  game_table.first_init
  bet = game_table.print_bet_choosing
  game_table.player.process_bet(bet)
  game_table.game(game_table.player)
end

main