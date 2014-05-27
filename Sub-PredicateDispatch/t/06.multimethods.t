use strict;
use warnings;

package Rock;  sub new { bless {} };
package Paper; sub new { bless {} };
package Scissors; sub new { bless {} };

package main;

use Test::More tests => 3;
use Sub::PredicateDispatch ':all';

generic play => sub { [ @_ ] };

multimethod play => classes( qw|Paper Rock| )     => 1;
multimethod play => classes( qw|Paper Scissors| ) => 0;
multimethod play => classes( qw|Rock Scissors| )  => 1;

my $rock  = Rock->new;
my $paper = Paper->new;
my $scissors = Scissors->new;

is(play($rock, $scissors), 1);
is(play($paper, $rock), 1);
is(play($paper, $scissors), 0);
