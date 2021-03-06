package Sangoku 0.01 {

  use strict;
  use warnings;
  use utf8;
  use feature qw/:5.20/;
  use Module::Load qw/autoload_remote/;

  sub import {
    my ($class, $option) = @_;
    $option //= '';

    if ($option eq 'test') {
      unshift @INC, './t/lib'; # テストの時パス追加
      my $pkg = caller;
      my @load = qw/Test::More Test::Exception Test::Sangoku/;
      autoload_remote($pkg, $_) for @load;
    }

    $class->import_pragma;
  }
  
  # インポートするプラグマ
  sub import_pragma {
    my ($class) = @_;
    $_->import for qw/strict warnings utf8/;
    feature->import(qw/:5.20/);
    # warnings->unimport('experimental::signatures');
  }
  
}

1;

__END__

=encoding utf8

=head1 名前
  
  Sangoku - NEO三国志NET基礎モジュール
  
=head1 メソッド
  
=head2 import
  
  モジュール読み込み時に実行されるメソッドです。
  use Sangoku;で普通にこのモジュールを読み込むと、読み込んだ側でuse strict,warnigns,utf8,feature:5.18が有効になります。
  
=cut
