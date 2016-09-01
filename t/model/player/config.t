use Sangoku 'test';
use Test::More;
use Test::Sangoku;
use Test::Sangoku::PostgreSQL;
use Test::Sangoku::Util qw/prepare_player_model_tests/;

use Sangoku::Model::Player;
use Sangoku::Model::Player::Config;

my $PLAYER_ID = Sangoku::Model::Player->ADMINISTARTOR_DATA->{player}{id};
my $TEST_CLASS = 'Sangoku::Model::Player::Config';
my $PSQL = Test::Sangoku::PostgreSQL->new();

prepare_player_model_tests();

subtest 'init' => sub {
  $TEST_CLASS->init();
  ok 1;
};

subtest 'create' => sub {
  ok $TEST_CLASS->create($PLAYER_ID);
};

subtest 'get' => sub {
  ok(my $config = $TEST_CLASS->get($PLAYER_ID));
  is $config->player_id, $PLAYER_ID;
};

done_testing();
