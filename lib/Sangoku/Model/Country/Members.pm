package Sangoku::Model::Country::Members {

  use Mouse;
  use Sangoku;
  with 'Sangoku::Model::Role::DB';

  use constant TABLE_NAME => 'country_members';

  has 'name' => (is => 'ro', isa => 'Str', required => 1);

  sub get {
    my ($self) = @_;
    my @rows = $self->db->search(TABLE_NAME, {country_name => $self->name});
    return \@rows;
  }

  sub add {
    my ($self, $player_id) = @_;
    $self->db->do_insert(TABLE_NAME, {
      country_name => $self->name,
      player_id    => $player_id,
    });
  }

  sub get_by_player_id {
    my ($class, $player_id) = @_;
    return $class->db->single(TABLE_NAME, {player_id => $player_id});
  }

  __PACKAGE__->meta->make_immutable();
}

1;
