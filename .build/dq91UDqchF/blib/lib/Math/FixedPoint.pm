package Math::FixedPoint;
use strict;
use warnings;
use overload
  '+'      => \&_add,
  fallback => 1;

# ABSTRACT: Fixed-Point arithmetic using integer

sub new {
    my ( $class, $num, $precision ) = @_;

    my ( $value, $decimal_places ) = $class->_parse_num( $num, $precision );
    my $self = bless {
        value          => $value,
        decimal_places => $decimal_places
    };
    return $self;
}

sub value          { $_[0]->{value} }
sub decimal_places { $_[0]->{decimal_places} }

sub _parse_num {
    my ( $class, $num, $precision ) = @_;

    if ( $num =~ /(\+|-)?(\d*)(?:\.(\d*))?(?:e(\+|-)?(\d+))?/ ) {
        my $sign = defined $1 && $1 eq '-' ? -1 : 1;
        my $integer = ( $2 || 0 ) * $sign;
        my $decimal = $3 || '';
        my $exp_sign = defined $4 && $4 eq '-' ? -1 : 1;
        my $exp = $5 || 0;

#        print STDERR
#"$num: sign:$sign integer:$integer decimal:$decimal exp_sign:$exp_sign, exp:$exp\n";

        my $decimal_places = length($decimal);
        $decimal_places -= $exp_sign * $exp;

        my $int = sprintf( "%0${decimal_places}d", $integer . $decimal );
        return ( $int, $decimal_places ) unless $precision;
        return ( $class->_coerce( $int, $decimal_places, $precision ),
            $precision );
    }
    else {
        die "Invalid number\n";
    }
}

sub _coerce {
    my ( $class, $num, $decimal_places, $precision ) = @_;

    print STDERR "$num, $decimal_places, $precision\n";

    if ( $precision >= $decimal_places ) {
        return $num * 10**( $precision - $decimal_places );
    }

    else {
        my $divisor = 10 ** ( $decimal_places - $precision );
        my $integer = $num // $divisor;
        print STDERR "int: $integer\n";
        my $reminder = $num % $divisor;
        if ( $reminder > $divisor / 2 ) {
            return $integer + 1;
        }
        return $integer;
    }

}

sub _add {
    my ( $self, $num ) = @_;
    if ( ref $num eq __PACKAGE__ ) {
        die "Problem" if $num->decimal_places != $self->{decimal_places};
        my $new = Math::FixedPoint->new( $self->{value} + $num->value );
        $new->{decimal_places} = $self->{decimal_places};
        return $new;
    }
    else {
        my $num2 = $self->new( $num, $self->{decimal_places} );
        return $self + $num2;
    }
}

1;
