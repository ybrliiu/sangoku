package Sangoku::Model::ForumReply {

  use Sangoku;
  use Mouse;
  with 'Sangoku::Model::Role::DB';

  use Sangoku::Util qw/validate_values datetime/;

  use constant TABLE_NAME => 'forum_reply';

  has 'thread_id' => (is => 'ro', isa => 'Int', required => 1);

  sub get {
    my ($self) = @_;
    my @result = $self->db->search(TABLE_NAME, {thread_id => $self->thread_id}, {order_by => 'id DESC'});
    return \@result;
  }

  sub add {
    my ($self, $args) = @_;
    validate_values($args => [qw/name icon message/]);

    $self->db->do_insert(TABLE_NAME, {
      %$args,
      thread_id => $self->thread_id,
      time      => datetime(),
    });
  }

  sub delete {
    my ($self, $id) = @_;

    if (ref $self) {
      $self->db->delete(TABLE_NAME, {thread_id => $self->thread_id});
    } else {
      $self->db->delete(TABLE_NAME, {id => $id});
    }

  }

  __PACKAGE__->meta->make_immutable();
}

1;