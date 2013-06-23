package Math::FixedPoint;
use strict;
use warnings;
use overload fallback => 1;

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
        return ( $int, $decimal_places );
    }
    else {
        die "Invalid number\n";
    }
}

1;
