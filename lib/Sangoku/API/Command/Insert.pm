package Sangoku::API::Command::Insert {

  use Mouse;
  use Sangoku;
  use Carp qw/croak/;

  has 'name' => (is => 'ro', isa => 'Str', default => '空白を入れる');

  with 'Sangoku::API::Command::Base';

  # method name is input but this module is insert command.
  sub input {
    my ($self, $args) = @_;
    validate_values($args => [qw/player_id insert_numbers num/]);
    my $model = $self->model('Player::Command')->new(id => $args->{player_id});
    $model->insert($args->{insert_numbers}, $args->{num});
  }

  sub execute { croak 'Insert Command cant execute!!' }

  __PACKAGE__->meta->make_immutable();
}

1;
