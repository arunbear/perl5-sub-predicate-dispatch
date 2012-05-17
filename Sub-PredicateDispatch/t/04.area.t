use strict;
use warnings;

use Test::More tests => 2;
use Math::Trig;
use Sub::PredicateDispatch ':all';

generic 'area' => sub { $_[0]->{shape} };

case_for 'area', square => sub { shift->{side} ** 2 };

case_for 'area', sub { $_[0] eq 'circle' } => sub { pi * shift->{radius} ** 2 };

my $square = { shape => 'square', side => 2 };
is(area($square), 4);

my $circle = { shape => 'circle', radius => 1 };
is(area($circle), pi);
