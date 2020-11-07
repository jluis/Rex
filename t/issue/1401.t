use Test::More tests => 7;

use strict;
use warnings;
use 5.010;
use autodie;
use English qw($OSNAME -no_match_vars);

use Rex::Commands::Run;

$::QUIET = 1;

my $win = $OSNAME =~ m/^MSWin/mxsi;

sub command {
  my ( $path, $exe, @parm ) = @_;
  return qq{$path$exe } . join q{}, @parm;
}

my $path = './inexistent path with spaces/';
ok( !-e $path, qq{"$path" not exists} );
my $quote      = q{"};
my $tail       = 'hello';
my $parm       = 'Rex is wonderfull';
my $s          = run command( $path, $tail, $parm );
my $not_exists = ( $win && !-e $path ) ? $s : qq{$path$tail};
diag($s);

like( $s, qr{(?-x:$not_exists)}smx,
  qq{windows dont return "$path$tail" on the message} );

ok( mkdir($path), qq{creating "$path"} );
my $cmd = $path . $tail;

if ($win) {

  #On windows we create hello.bat contaning echo %1
  $cmd .= q{.bat};
  open my $hello, '>', $cmd;
  print {$hello} "echo %*\n";
  close $hello;
}
else {
  #hello is a sybolic link to echo
  my $echo = '/bin/echo';
  if ( !-X $echo ) {
    substr $echo, 0, 0, q{/usr};
  }
  symlink $echo, $cmd;
}

my $result = qr{(?-x:$parm)}smx;

$s = run command( $path, $tail, $parm );
like( $s, $result, qq{"$path$tail $parm"  ok} );

$s = run command( $path, $tail, q{/}, $parm );
like( $s, $result, '/slash on parms ok' );

$s = run command( $quote . $path, $tail . $quote, $parm );
like( $s, $result, 'Quoted commands ok' );
my $mpath = $path;

if ($win) {
  $mpath =~ s{/}{\\}gsmx;
  $s = run command( $mpath, $tail, $parm );
  like( $s, $result, "($mpath$tail $parm) windows path ok" );
}
else {
  $mpath =~ s{(\s)}{\\$1}gsmx;
  $s = run command( $mpath, $tail, $parm );
  like( $s, $result, "($mpath $parm) back slash escapes ok" );
}

unlink $cmd;
rmdir $path;
