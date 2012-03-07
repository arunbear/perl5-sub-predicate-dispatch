use strict;
use warnings;

use Test::More tests => 4;
use Sub::PredicateDispatch;

my $signal = Sub::PredicateDispatch->new();
$signal->when(go => sub { 'green' })
       ->when(stop => sub { 'red' });

is($signal->('go'), 'green');
is($signal->('stop'), 'red');

$signal->default('unknown');
is($signal->('yield'), 'unknown', 'default case');

$signal->when(yield => 'yellow');
is($signal->('yield'), 'yellow');
