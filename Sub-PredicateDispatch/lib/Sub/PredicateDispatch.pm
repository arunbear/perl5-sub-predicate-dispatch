use strict;
package Sub::PredicateDispatch;

sub new {
    my ($class, %arg) = @_;

    my $f = sub { 
        my $it = shift;
        $arg{when}{ $arg{dispatch}->($it) }->($it);  
    };
    return bless $f => $class;
}

1;
