require "test/unit"
require_relative '../src/black_jack'

class TestCard < Test::Unit::TestCase
  def test_card_representation
    assert_equal('2', Card.new(1).view)
    assert_equal('A', Card.new(52).view)
    assert_equal('A', Card.new(51).view)
    assert_equal('J', Card.new(40).view)
    assert_equal('Q', Card.new(41).view)
  end
end

class TestUser < Test::Unit::TestCase
  def test_first_state_simple
    $deck = (1..52).to_a
    $current_index = 0
    player = User.new
    dealer = User.new
    player.first_init(true)
    assert_equal(['2', '2'], player.hand)
    assert_equal(4, player.score)
    assert_equal(4, player.ace_score)

    $current_index = 50
    dealer.first_init(false)
    assert_equal(['A', 'A'], dealer.hand)
    assert_equal(11, dealer.score)
    assert_equal(1, dealer.ace_score)
    dealer.update_score
    assert_equal(22, dealer.score)
    assert_equal(2, dealer.ace_score)
  end

  def test_update_money
    player = User.new
    player.process_bet(1)
    assert_equal(10, player.bet)
    player.update_money(true, false)
    assert_equal(1010, player.money)
    player.process_bet(25)
    assert_equal(25, player.bet)
    player.update_money(false, true)
    assert_equal(1010, player.money)
    player.process_bet(3)
    assert_equal(100, player.bet)
    player.update_money(false, false)
    assert_equal(910, player.money)
  end
end

class TestTable < Test::Unit::TestCase
  $table = Table.new
  def test_case_black_jack
    $table.player.hand = ['A', 'Q']
    $table.player.score = 21
    $table.player.bet = 10
    $table.dealer.hand = ['A', 'Q']
    $table.dealer.score = 11
    $table.case_black_jack($table.player)
    assert_equal(1010, $table.player.money)
    $table.dealer.hand = ['7', '6']
    $table.dealer.score = 7
    $table.player.bet = 10
    $table.case_black_jack($table.player)
    assert_equal(1030, $table.player.money)
  end

  def make_player(player, score, bet, money)
    player.score = score
    player.bet = bet
    player.money = money
  end

  def test_get_winner
    make_player($table.player, 20, 10, 990)
    make_player($table.dealer, 17, 0, 0)
    $table.get_winner($table.player)
    assert_equal(1010, $table.player.money)

    make_player($table.player, 20, 10, 990)
    make_player($table.dealer, 23, 0, 0)
    $table.get_winner($table.player)
    assert_equal(1010, $table.player.money)

    make_player($table.player, 20, 10, 990)
    make_player($table.dealer, 20, 0, 0)
    $table.get_winner($table.player)
    assert_equal(1000, $table.player.money)

    make_player($table.player, 17, 10, 990)
    make_player($table.dealer, 20, 0, 0)
    $table.get_winner($table.player)
    assert_equal(990, $table.player.money)
    assert_equal(0, $table.player.bet)
  end
end