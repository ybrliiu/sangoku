package Test::Jikkoku {
  
  use Jikkoku;
  
  use Exporter 'import';
  our @EXPORT = qw/dump_yaml/;
  
  use YAML::Dumper;
  use Data::Dumper;
  # Data::Dumperで無理やりutf8文字を表示させる
  package Data::Dumper {
    no warnings 'redefine';
    sub qquote { return shift; }
  }
  $Data::Dumper::Useperl = 1;
  
  # YAMLでダンプ
  sub dump_yaml {
    my $data = shift;
    state $dumper;
    return $dumper->dump($data) if $dumper;
    $dumper = YAML::Dumper->new();
    $dumper->indent_width(4);
    return $dumper->dump($data);
  }
  
}

1;

__END__

=encoding utf-8

=head1 名前
  
  Test::Jikkoku - 十国志NETのためのTestモジュール
  
=head1 備考
  
  dump_yaml 関数が自動的にインポートされます
  
=head1 関数
  
=head2 dump_yaml($ref)
  
  渡したデータ(リファレンス)をYAMLでダンプ、データの中身を表示します
  使用例) 
  my $hash = {hoge => 'hoge'};
  dump_yaml($hash);
  
=cut
