package Sub::PredicateDispatch;

# ABSTRACT: Predicate Dispatch for Perl

use strict;
use Data::Compare;
use Exporter 'import';
use Params::Validate qw(:all);
use Sub::Install;

use Exception::Class ('Sub::PredicateDispatch::E::NoDefault');

our @EXPORT_OK = qw(generic multimethod defaultmethod classes);
our %EXPORT_TAGS = (all => [@EXPORT_OK]);

sub new {
    my $class = shift;
    my %arg = validate(@_, {
        dispatch => { type => CODEREF,  default => sub { $_[0] } },
        when     => { type => ARRAYREF, default => [] },
        default  => { type => CODEREF | SCALAR | UNDEF, optional => 1 },
        name     => { type => SCALAR  | UNDEF, optional => 1 },
    });

    my $f = sub { 
        if((caller)[0] eq __PACKAGE__) {
            return \%arg;
        }

        my $dispatch_val = $arg{dispatch}->(@_);

        my @when = @{ $arg{when} };
        while(my ($pred, $action) = splice @when, 0, 2) {
            my $matched = do {
                my $ref = ref $pred;
                if (! $ref) {
                    $pred eq $dispatch_val;
                }
                elsif ($ref eq 'CODE') {
                    $pred->($dispatch_val);
                }
                else {
                    Compare($pred, $dispatch_val);
                }
            };
            if($matched) {
                return ref $action eq 'CODE' ? $action->(@_) : $action;
            }
        }
        if(exists $arg{default}) {
            my $default = $arg{default};
            return ref $default eq 'CODE' ? $default->(@_) : $default;
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

sub when {
    my $self = shift;
    validate_pos(@_, 1, 1);

    my $dispatch_href = $self->();
    push @{ $dispatch_href->{when} }, @_;
    return $self;
}

sub default {
    my ($self, $default) = @_;

    my $dispatch_href = $self->();
    $dispatch_href->{default} = $default;
    return $self;
}

my %Object;

sub generic {
    if ( ! @_ ) {
        return __PACKAGE__->new;
    }

    my %arg;
    my @a = (shift);
    ($arg{name}) = validate_pos(@a, { type => SCALAR });

    if ( my $code = shift ) {
        $arg{dispatch} = $code;
    }

    my $package = (caller)[0];
    my $full_name = "${package}::$arg{name}";
    my $obj = __PACKAGE__->new(%arg);
    $Object{$full_name} = $obj;
    $obj->()->{full_name} = $full_name;
    return $obj;
}

sub multimethod {
    my @a = (shift);
    my ($name) = validate_pos(@a, { type => SCALAR });
    my $package = (caller)[0];
    my $obj = $Object{"${package}::$name"};
    $obj->when(@_);
}

sub defaultmethod {
    my @a = (shift);
    my ($name) = validate_pos(@a, { type => SCALAR });
    my $default = shift;
    my $package = (caller)[0];
    my $obj = $Object{"${package}::$name"};
    $obj->default($default);
}

# Predicate builder for CLOS style multimethods
*classes = test_objects_with('isa');

*roles = test_objects_with('DOES');

sub test_objects_with {
    my $test = shift;
    return sub {
        my @pkgs = @_;
        return sub {
            my $aref = shift;
            return unless @$aref == @pkgs;

            my $matched = 1;

            foreach my $i ( 0 .. $#pkgs ) {
                my $class = $pkgs[$i];
                my $obj   = $aref->[$i];
                $matched &&= $obj->$test($class);
            }
            return $matched; 
        }
    }
}

DESTROY {
    my ($self) = @_;

    my $guts = $self->();

    if ( exists $guts->{full_name} ) {
        delete $Object{ $guts->{full_name} };
    }
}

1;

__END__
=pod

=head1 SYNOPSIS

    # Keyword style:

    use Math::Trig;
    use Sub::PredicateDispatch ':all';

    generic 'area' => sub { $_[0]->{shape} };

    multimethod 'area', square => sub { shift->{side} ** 2 };

    multimethod 'area', sub { $_[0] eq 'circle' } => sub { pi * shift->{radius} ** 2 };

    my $square = { shape => 'square', side => 2 };
    print area($square) . "\n"; # 4

    my $circle = { shape => 'circle', radius => 1 };
    print area($circle) . "\n"; # 3.14...

    
    # OO style:
    
    use Sub::PredicateDispatch;
    use Math::Trig;

    my $area = Sub::PredicateDispatch->new(
        dispatch => sub { $_[0]->{shape} },
        when => [
            square => sub { shift->{side} ** 2 },
            sub { $_[0] eq 'circle' } => sub { pi * shift->{radius} ** 2 }, 
        ],
    );

    my $square = { shape => 'square', side => 2 };
    print $area->($square) . "\n"; # 4

    my $circle = { shape => 'circle', radius => 1 };
    print $area->($circle) . "\n"; # 3.14...

=head1 DESCRIPTION

This module provides an implementation of Predicate Dispatch, a mechanism that generalizes
the method dispatch system found in Object Oriented languages.

Rather than dispatching based on the class of the invoking object (as with single dispatch languages),
or on the classes of more than one of the method's arguments (as with languages supporting multiple dispatch),
predicate dispatch enables dispatch based on arbitrary properties of the method's arguments which need 
not even be objects.

The implementation here is inspired by a JavaScript implementation (L<http://krisjordan.com/multimethod-js>),
which itself is inspired by the multimethod construct from the Clojure language (L<http://clojure.org/multimethods>).

=head1 INTERFACE


=head1 EXAMPLES


