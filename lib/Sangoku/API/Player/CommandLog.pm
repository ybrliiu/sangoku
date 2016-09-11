package Sangoku::API::Player::CommandLog {

  use Sangoku;
  use Mouse;
  with 'Sangoku::API::Role::Record::Log';

  use overload (
    q{""}    => 'string',
    fallback => 1,
  );

  sub file_path { 
    my ($class, $id)  = @_;
    return "etc/record/player/command_log/$id.dat";
  }

  __PACKAGE__->meta->make_immutable();
}

1;
