use Test::More tests => 1;

use Rex::Commands::Run;

$::QUIET = 1;

SKIP: {
  skip 'Do not run tests on Windows', 1 if $^O =~ m/^MSWin/;i

  my $cmd = '/tmp/path with spaces/hello'
  my $s = run $cmd;
  like( $s, qr/$cmd/, "correct path on error" );
}
