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

    if ( $num =~ /(+|-)?(\d*)(?:\.(\d*))(?:e(+|-)(\d+))/ ) {
        print "sign:$1 integer:$2 decimal:$3 exp_sign:$4, exp:$5\n";
    }

    if ( my $index = index( $num, '.' ) > -1 ) {
        if ( my $exp_index = index( $num, 'e', $index + 1 ) > -1 ) {
            my $exp            = substr( $num, -$exp_index - 1 );
            my $decimal_places = int($exp) - $index - $exp_index;
            my $num =
                substr( $num, 0, $index )
              . substr( $num, $index + 1, $exp_index - $index - 2 );
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
