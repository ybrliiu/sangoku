package Sangoku::Service::Player::Mypage {

  use Mouse;
  use Sangoku;
  with 'Sangoku::Service::Role::Base';

  use Carp qw/croak/;
  use Sangoku::Util qw/validate_values escape/;

  sub root {
    my ($class, $player_id) = @_;

    my $config         = $class->config->{template}{player}{mypage};
    my $players_hash   = $class->model('Player')->get_all_to_hash;
    my $player         = $class->model('Player')->get_joined($player_id);
    my $unit           = $player->unit;
    my $countreis_hash = $class->model('Country')->get_all_to_hash();
    my $country        = $player->country($countreis_hash);
    my $towns          = $class->model('Town')->get_all();
    my $towns_hash     = $class->model('Town')->to_hash($towns);
    my $town           = $player->town($towns_hash);

    my ($letter, $unread_letter, $transmission_history) = @{ $class->_get_letter({
      player  => $player,
      unit    => $unit,
      country => $country,
      town    => $town,
      config  => $config->{letter},
    }) };

    return {
      player               => $player,
      players_hash         => $players_hash,
      command_log          => $player->command_log($config->{log}{command}),
      countries_hash       => $countreis_hash,
      country              => $country,
      unit                 => $unit,
      towns                => $towns,
      map_data             => $class->model('Town')->get_all_for_map($towns_hash),
      town                 => $player->town,
      command_list         => $class->model('Command')->get_list(),
      site                 => $class->model('Site')->get(),
      login_list           => $class->model('LoginList')->get( $player ),
      map_log              => $class->model('MapLog')->get($config->{log}{map}),
      letter               => $letter,
      unread_letter        => $unread_letter,
      letter_limit         => $config->{letter},
      transmission_history => $transmission_history,
    };
  }

  sub letter_log {
    my ($class, $player_id) = @_;

    my $config         = $class->config->{template}{player}{mypage};
    my $players_hash   = $class->model('Player')->get_all_to_hash;
    my $player         = $class->model('Player')->get_joined($player_id);
    my $unit           = $player->unit;
    my $countreis_hash = $class->model('Country')->get_all_to_hash();
    my $country        = $player->country($countreis_hash);
    my $town           = $player->town;

    my ($letter, $unread_letter, $transmission_history) = @{ $class->_get_letter({
      player  => $player,
      unit    => $unit,
      country => $country,
      town    => $town,
      config  => $config->{letter_log},
    }) };

    return {
      player               => $player,
      players_hash         => $players_hash,
      countries_hash       => $countreis_hash,
      country              => $country,
      unit                 => $unit,
      town                 => $player->town,
      letter               => $letter,
      unread_letter        => $unread_letter,
      letter_limit         => $config->{letter_log},
      transmission_history => $transmission_history,
    };
  }

  sub _get_letter {
    my ($class, $args) = @_;
    my ($player, $unit, $country, $town, $config) = map { $args->{$_} } qw/player unit country town config/;
    my $read_letter = $player->read_letter,

    my %letter_model = (
      player  => $player->letter_model,
      unit    => $player->unit_letter_model,
      invite  => $player->invite_model,
      country => $country->letter_model,
      town    => $town->letter_model,
    );

    my %letter      = map { $_ => $letter_model{$_}->get( $config->{$_} ) } qw/town invite country/;
    $letter{player} = $letter_model{player}->get_without_same_letter($player, $config->{player});
    $letter{unit}   = $player->unit_letter($letter_model{unit}, $config->{unit});

    my %unread_letter = map {
      my $key = $_;
      if (defined $letter_model{$key}) {
        my $unread_letter = $letter_model{$key}->unread_letter($letter{$key}, $read_letter->$key);
        $key => $unread_letter;
      } else {
        ();
      }
    } keys %letter_model;

    my $transmission_history = $letter_model{player}->transmission_history( $config->{transmission_history} );

    return [\%letter, \%unread_letter, $transmission_history];
  }

  sub get_player {
    my ($class, $player_id) = @_;
    return $class->model('Player')->get_joined($player_id);
  }

  sub write_letter {
    my ($class, $args) = @_;
    validate_values($args => [qw/type message/]);
    my $type = $args->{type};
    $args->{message} = escape( $args->{message} );

    state $switch_method = {map { $_ => "_write_${_}_letter" } qw/player unit country town/};

    my $method = $switch_method->{$type};
    my ($letter_data, $sender) = defined $method
      ? $class->$method($args)
      : croak "不正な letter type が指定されています($type)";
    $letter_data->{type} = $type;
    return ($letter_data, $sender);
  }

  sub _write_player_letter {
    my ($class, $args) = @_;
    validate_values($args => [qw/sender_id receiver_name message/]);

    my $player_model = $class->model('Player');
    my $sender   = $player_model->get($args->{sender_id});
    my $receiver = $player_model->get_by_name($args->{receiver_name});
    my $letter_data = $class->model('Player::Letter')->new(id => $sender->id)->add({
      sender   => $sender,
      receiver => $receiver,
      message  => $args->{message},
    });
    return ($letter_data, $sender);
  }

  sub _write_country_letter {
    my ($class, $args) = @_;
    validate_values($args => [qw/sender_id receiver_name message/]);

    my $sender = $class->model('Player')->get($args->{sender_id});
    my $letter_data = $class->model('Country::Letter')->new(name => $sender->country_name)->add({
      sender        => $sender,
      receiver_name => $args->{receiver_name},
      message       => $args->{message},
    });
    return ($letter_data, $sender);
  }

  sub _write_town_letter {
    my ($class, $args) = @_;
    validate_values($args => [qw/sender_id message/]);

    my $sender = $class->model('Player')->get($args->{sender_id});
    my $letter_data = $class->model('Town::Letter')->new(name => $sender->town_name)->add({
      sender  => $sender,
      message => $args->{message},
    });
    return ($letter_data, $sender);
  }

  sub _write_unit_letter {
    my ($class, $args) = @_;
    validate_values($args => [qw/sender_id message/]);

    my $sender = $class->model('Player')->get($args->{sender_id});
    croak "部隊に所属していません" unless $sender->is_belong_unit;

    my $unit = $sender->unit;
    my $letter_model = $class->model('Unit::Letter')->new({
      id   => $unit->id,
      name => $unit->name,
    });
    my $letter_data = $letter_model->add({
      sender  => $sender,
      message => $args->{message},
    });
    return ($letter_data, $sender);
  }

  sub write_read_letter_id {
    my ($class, $args) = @_;
    my @params = qw/player_id type id/;
    validate_values($args => \@params);
    my ($player_id, $type, $id) = map { $args->{$_} } @params;

    my $model = $class->model('Player::ReadLetter')->new(id => $player_id);
    my $rec = $model->record->open('LOCK_EX');
    my $read_letter = $rec->at(0);
    croak "$type という手紙テーブルは存在していません" unless $read_letter->can($type);
    $read_letter->$type($id);
    $rec->close();
  }

  __PACKAGE__->meta->make_immutable();
}

1;
