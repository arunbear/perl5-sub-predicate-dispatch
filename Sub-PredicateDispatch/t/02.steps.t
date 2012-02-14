use strict;
use warnings;

use Test::More tests => 3;
use Sub::PredicateDispatch;

my $signal = Sub::PredicateDispatch->new();
$signal->when(go => sub { 'green' })
       ->when(stop => sub { 'red' });

is($signal->('go'), 'green');
is($signal->('stop'), 'red');

$signal->when(yield => 'yellow');
is($signal->('yield'), 'yellow');
