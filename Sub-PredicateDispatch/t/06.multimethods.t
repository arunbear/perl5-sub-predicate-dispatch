use strict;
use warnings;

package Rock;  sub new { bless {} };
package Paper; sub new { bless {} };
package Scissors; sub new { bless {} };

package main;

use Test::More tests => 3;
use Sub::PredicateDispatch ':all';

generic 'play' => sub { [map(ref, @_)] };

multimethod 'play', [qw/Paper Rock/]     => sub { 1 };
multimethod 'play', [qw/Paper Scissors/] => sub { 0 };
multimethod 'play', [qw/Rock Scissors/]  => sub { 1 };

my $rock  = Rock->new;
my $paper = Paper->new;
my $scissors = Scissors->new;

is(play($rock, $scissors), 1);
is(play($paper, $rock), 1);
is(play($paper, $scissors), 0);
