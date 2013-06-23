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

    if ( my $index = index( $num, '.' ) > -1 ) {
        if ( my $exp_index = index( $num, 'e', $index + 1 ) ) {
            my $exp            = substr( $num, -$exp_index - 1 );
            my $decimal_places = int($exp) - $index - $exp_index;
            my $decimal_places = $index + 1;
            my $num =
              substr( $num, 0, $index ) . substr( $num, -$decimal_places );
            return ( $num, $decimal_places );
        }
        else {
            my $decimal_places = $index + 1;
            my $num =
              substr( $num, 0, $index ) . substr( $num, -$decimal_places );
            return ( $num, $decimal_places );
        }
    }

    else {
        return ( $num, 0 );
    }
}

1;