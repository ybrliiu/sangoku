package Sangoku::Model::Role::DB::Letter {

  use Sangoku;
  use Mouse::Role;
  with 'Sangoku::Model::Role::DB';

  use Sangoku::Util qw/validate_values datetime/;

  has 'where'       => (is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build_where');
  has 'letter_type' => (is => 'rw', isa => 'Str', lazy => 1, builder => '_build_letter_type');

  sub _build_where {
    my ($self) = @_;

    my $meta = $self->meta;

    my $attribute_name = do {
      # Unit::Letter, Player::Letter, Player::Invite
      if ( $meta->has_attribute('id') ) {
        'id';
      }
      # Town::Letter, Country::Letter
      elsif ( $meta->has_attribute('name') ) {
        'name';
      } else {
        die 'id もしくは name attributeが見つかりませんでした。';
      }
    };

    my $parent_table = $self->letter_type;
    return {"${parent_table}_${attribute_name}" => $self->$attribute_name};
  }

  sub _build_letter_type {
    my ($self) = @_;
    my $letter_type= lc( (split /::/, ref $self)[2] );
    return $letter_type;
  }

  sub get {
    my ($self, $limit) = @_;
    my @rows = $self->db->search(
      $self->TABLE_NAME,
      $self->where,
      {
        order_by => 'id DESC',
        defined $limit ? (limit => $limit) : (),
      },
    );
    return \@rows;
  }

  sub unread_letter {
    my ($self, $letters, $read_letter_id) = @_;
    my $unread_letter = 0;
    for my $letter (@$letters) {
      $unread_letter++ if $read_letter_id < $letter->id;
    }
    return $unread_letter;
  }

  sub add {
    my ($self, $args) = @_;
    validate_values($args => [qw/sender message/]);

    my %letter_data = (
      sender_name         => $args->{sender}->name,
      sender_icon         => $args->{sender}->icon,
      sender_town_name    => $args->{sender}->town_name,
      sender_country_name => $args->{sender}->country_name,
      receiver_name       => $self->name,
      message             => $args->{message},
      time                => datetime(),
    );

    my $letter = $self->db->insert($self->TABLE_NAME, {%{ $self->where }, %letter_data});

    require Sangoku::Model::Player::Letter;
    $letter_data{letter_type} = $self->letter_type;
    Sangoku::Model::Player::Letter->new(id => $args->{sender}->id)->add_sended(\%letter_data);

    $letter_data{id} = $letter->id;
    return \%letter_data;
  }

}

1;
