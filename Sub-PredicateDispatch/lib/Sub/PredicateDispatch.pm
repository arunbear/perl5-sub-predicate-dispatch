package Sub::PredicateDispatch;

use strict;
use Params::Validate qw(:all);

sub new {
    my $class = shift;
    my %arg = validate(@_, {
        dispatch => { type => CODEREF,  default => sub { $_[0] } },
        when     => { type => ARRAYREF, default => [] },
    });

    my $f = sub { 
        if((caller)[0] eq __PACKAGE__) {
            return \%arg;
        }

        my $it = shift;
        my $dispatch_val = $arg{dispatch}->($it);

        my @when = @{ $arg{when} };
        while(my ($pred, $action) = splice @when, 0, 2) {
            my $matched = ref $pred eq 'CODE' 
              ? $pred->($dispatch_val) 
              : $pred eq $dispatch_val;
            if($matched) {
                return ref $action eq 'CODE' ? $action->($it) : $action;
            }
        }
    };
    return bless $f => $class;
}

sub when {
    my $self = shift;
    validate_pos(@_, 1, 1);

    my $dispatch_href = $self->();
    push @{ $dispatch_href->{when} }, @_;
    return $self;
}

1;
