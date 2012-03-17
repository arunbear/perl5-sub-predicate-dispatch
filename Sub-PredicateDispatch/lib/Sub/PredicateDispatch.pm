package Sub::PredicateDispatch;

# ABSTRACT: Predicate Dispatch for Perl

use strict;
use Exporter 'import';
use Params::Validate qw(:all);
use Sub::Install;

use Exception::Class ('Sub::PredicateDispatch::E::NoDefault');

our @EXPORT_OK = qw(gsub);

sub new {
    my $class = shift;
    my %arg = validate(@_, {
        dispatch => { type => CODEREF,  default => sub { $_[0] } },
        when     => { type => ARRAYREF, default => [] },
        default  => { type => CODEREF | UNDEF, optional => 1 },
        name     => { type => SCALAR  | UNDEF, optional => 1 },
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
        if(exists $arg{default}) {
            my $default = $arg{default};
            return ref $default eq 'CODE' ? $default->($it) : $default;
        }
        else {
            Sub::PredicateDispatch::E::NoDefault->throw;
        }
    };

    bless $f => $class;
    if ( $arg{name} ) {
        Sub::Install::install_sub({
            code => $f,
            into => (caller(1))[0],
            as   => $arg{name},
        });
    }
    return $f;
}

sub gsub {
    __PACKAGE__->new(@_);
}

sub when {
    my $self = shift;
    validate_pos(@_, 1, 1);

    my $dispatch_href = $self->();
    push @{ $dispatch_href->{when} }, @_;
    return $self;
}

sub default {
    my $self = shift;
    my ($default) = validate_pos(@_, 1);

    my $dispatch_href = $self->();
    $dispatch_href->{default} = $default;
    return $self;
}

1;
