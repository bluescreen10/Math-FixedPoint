package Math::FixedPoint;
use strict;
use warnings;
use overload fallback => 1;

# ABSTRACT: Fixed-Point arithmetic using integer

sub new {
    my ( $class, $num, $precision ) = @_;

    my ( $value, $decimal_places ) = $class->_parse_num($num, $precision);
    my $self = bless {
        value          => $value,
        decimal_places => $decimal_places
    };
    return $self;
}

1;
