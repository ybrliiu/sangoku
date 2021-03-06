package Sangoku::DB::Exception {

  use Sangoku;
  use parent 'Exception::Tiny';

  use Carp qw/confess/;
  use Class::Accessor::Lite new => 0;
  Class::Accessor::Lite->mk_ro_accessors(qw/reason sql bind call_package call_file call_line call_sub trace/);

  use Sangoku::Util 'validate_values';

  sub throw {
    my ($class, %args) = @_;
    validate_values(\%args => [qw/message reason sql bind/]);
    $class->_throw(\%args);
  }

  sub _throw {
    my ($class, $args, $code) = @_;

    my %args = %$args;
    ($args{package}, $args{file}, $args{line}) = caller(4);
    ($args{call_package}, $args{call_file}, $args{call_line}, $args{call_sub}) = caller(5);
    
    eval { confess 'trace start' };
    $args{trace} = $@;

    my $self = $class->new(%args);
    $code->($self) if defined $code;
    die $self;
  }

  sub as_string {
    my ($self) = @_;
    my $class = ref $self;

    require Data::Dumper;
    local $Data::Dumper::Maxdepth = 2;
    # 英文字以外が文字化けしないように
    no warnings 'redefine';
    local *Data::Dumper::qquote = sub { shift };
    local $Data::Dumper::Useperl = 1;

    my $format = <<"EOF";
[%s]

%s at %s line %s.
  %s called at %s line %s.

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Reason  : %s
SQL     : %s
Trace   : %s
BIND    : %s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

EOF
    sprintf $format => (
      $class,
      $self->{message}, $self->{file}, $self->{line},
      $self->{call_sub}, $self->{call_file}, $self->{call_line},
      $self->{reason}, $self->{sql}, $self->{trace}, Data::Dumper::Dumper($self->{bind}),
    );
  }

}

1; 
