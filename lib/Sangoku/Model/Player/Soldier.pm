package Sangoku::Model::Player::Soldier {

  use Sangoku;
  use Mouse;
  with 'Sangoku::Model::Role::DB';

  use constant TABLE_NAME => 'player_soldier';

  sub get {
    my ($class, $id) = @_;
    return $class->db->single(TABLE_NAME() => {player_id => $id});
  }

  sub create {
    my ($class) = @_;
    $class->db->do_insert(TABLE_NAME() => {});
  }

  __PACKAGE__->meta->make_immutable();
}

1;
