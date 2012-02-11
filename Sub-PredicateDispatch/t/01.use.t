use strict;
use warnings;

use Test::More tests => 1;

use Sub::PredicateDispatch;

my $area = Sub::PredicateDispatch->new(
    dispatch => sub { $_[0]->{shape} },
    when => {
        square => sub { shift->{side} ** 2 }
    },
);

my $square = { shape => 'square', side => 2 };
is($area->($square), 4);
