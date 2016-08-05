package Sangoku::Web {

  use Mojo::Base 'Mojolicious';

  # This method will run once at server start
  sub startup {
    my $self = shift;

    # Router
    my $r = $self->routes;
    $r->namespaces(['Sangoku::Web::Controller']);

    # Normal route to controller
    $r->get('/')->to('example#welcome');
  }

}

1;