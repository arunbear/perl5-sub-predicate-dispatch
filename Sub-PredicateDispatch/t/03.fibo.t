use strict;
use warnings;

use Test::More;
use Sub::PredicateDispatch ':all';

generic 'fibo';

case_for 'fibo', 0 => 0;
case_for 'fibo', 1 => 1;
default_for 'fibo' => sub {
    my $n = shift;
    return fibo($n - 1) + fibo($n - 2);
};

is(fibo(0),  0);
is(fibo(1),  1);
is(fibo(2),  1);
is(fibo(3),  2);
is(fibo(10), 55);
is(fibo(20), 6765);
done_testing();
