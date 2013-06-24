package Math::FixedPoint;
use strict;
use warnings;
use Carp qw(croak);

use overload
  '+'      => \&_add,
  '+='     => \&_add_inplace,
  '-'      => \&_substract,
  '-='     => \&_substract_inplace,
  '*'      => \&_multiply,
  '*='     => \&_multiply_inplace,
  '/'      => \&_division,
  '/='     => \&_division_inplace,
  '='      => \&_copy,
  '""'     => \&_stringify,
  'int'    => \&_intify,
  fallback => 1;

# ABSTRACT: Fixed-Point arithmetic using integers

sub new {
    my ( $class, $num, $precision ) = @_;

    my $self = {};

    if ( defined $num ) {
        my ( $value, $decimal_places ) = _parse_num( $num, $precision );
        $self->{value}          = $value;
        $self->{decimal_places} = $decimal_places;
    }

    else {
        $self->{value}          = 0;
        $self->{decimal_places} = 0;
    }

    bless $self, $class;
}

sub value {
    my $self = shift;
    $self->{value} = shift if @_;
    return $self->{value};
}

sub decimal_places {
    my $self = shift;
    $self->{decimal_places} = shift if @_;
    return $self->{decimal_places};
}

sub _parse_num {
    my ( $str, $precision ) = @_;

    if ( int($str) eq $str ) {
        return defined $precision
          ? ( $str . '0' x $precision, $precision )
          : ( $str, 0 );
    }

    elsif ( $str =~ /^  ([-+]?)(\d*)  (?:\.(\d+))?  (?:[eE]([-+]?\d+))?  $/x ) {

        my $sign = defined $1 && $1 eq '-' ? '-' : '';
        my $num     = $2 || 0;
        my $decimal = $3 || '';
        my $exp     = $4 || 0;

        my $decimal_places = length($decimal);
        $decimal_places -= $exp;

        my $value =
            $decimal_places < 0
          ? $sign . $num . $decimal . ( '0' x -$decimal_places )
          : sprintf( "${sign}%0${decimal_places}s", $num . $decimal );

        $decimal_places = 0 if $decimal_places < 0;

        return
          defined $precision
          ? ( _coerce( $value, $decimal_places, $precision ), $precision )
          : ( $value, $decimal_places );
    }
    else {
        croak "$str not a valid number";
    }
}

sub _coerce {
    my ( $num, $decimal_places, $precision ) = @_;

    if ( $precision >= $decimal_places ) {
        return $num . '0' x ( $precision - $decimal_places );
    }

    else {
        my $places   = $precision - $decimal_places;
        my $reminder = substr( $num, $places );
        my $new_num  = substr( $num, 0, $places );

        $new_num++ if $num >= 0 and $reminder > 5 * 10**( -1 * $places - 1 );
        $new_num-- if $num < 0  and $reminder > 5 * 10**( -1 * $places - 1 );

        return $new_num;
    }
}

sub _add {
    my ( $self, $num ) = @_;

    my $decimal_places = $self->{decimal_places};
    my $value          = $self->{value};
    my $new_value;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ($new_value) = _parse_num( $num, $decimal_places );
    }

    else {
        $new_value =
            $decimal_places == $num->{decimal_places}
          ? $num->{value}
          : _coerce( $num->{value}, $num->{decimal_places}, $decimal_places );

    }

    my $new = Math::FixedPoint->new;
    $new->{value}          = $new_value + $value;
    $new->{decimal_places} = $decimal_places;
    return $new;
}

sub _add_inplace {
    my ( $self, $num ) = @_;

    my $decimal_places = $self->{decimal_places};
    my $value          = $self->{value};
    my $new_value;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ($new_value) = _parse_num( $num, $decimal_places );
    }

    else {
        $new_value =
            $decimal_places == $num->{decimal_places}
          ? $num->{value}
          : _coerce( $num->{value}, $num->{decimal_places}, $decimal_places );
    }

    $self->{value} += $new_value;
    return $self;
}

sub _copy {
    my $self = shift;
    my $new  = Math::FixedPoint->new;
    $new->{value}          = $self->{value};
    $new->{decimal_places} = $self->{decimal_places};
    return $new;
}

sub _multiply {
    my ( $self, $num ) = @_;

    my $decimal_places = $self->{decimal_places};
    my $value          = $self->{value};
    my $new_value;
    my $new_decimal_places;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ( $new_value, $new_decimal_places ) = _parse_num($num);

        $new_value = _coerce(
            $value * $new_value,
            $new_decimal_places + $decimal_places,
            $decimal_places
        );
    }
    else {
        $new_value = _coerce(
            $value * $num->{value},
            $decimal_places + $num->{decimal_places},
            $decimal_places
        );
    }

    my $new = Math::FixedPoint->new;
    $new->{value}          = $new_value;
    $new->{decimal_places} = $decimal_places;
    return $new;
}

sub _multiply_inplace {
    my ( $self, $num ) = @_;

    my $decimal_places = $self->{decimal_places};
    my $value          = $self->{value};
    my $new_value;
    my $new_decimal_places;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ( $new_value, $new_decimal_places ) = _parse_num($num);

        $new_value = _coerce(
            $value * $new_value,
            $new_decimal_places + $decimal_places,
            $decimal_places
        );
    }
    else {
        $new_value = _coerce(
            $value * $num->{value},
            $decimal_places + $num->{decimal_places},
            $decimal_places
        );
    }

    $self->{value} = $new_value;
    return $self;
}

sub _substract {
    my ( $self, $num, $reverse ) = @_;

    my $decimal_places = $self->{decimal_places};
    my $value          = $self->{value};
    my $new_value;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ($new_value) = _parse_num( $num, $decimal_places );
    }

    else {
        $new_value =
            $decimal_places == $num->{decimal_places}
          ? $num->{value}
          : _coerce( $num->{value}, $num->{decimal_places}, $decimal_places );
    }

    my $new = Math::FixedPoint->new;
    $new->{value} = $reverse ? $new_value - $value : $value - $new_value;
    $new->{decimal_places} = $decimal_places;
    return $new;
}

sub _substract_inplace {
    my ( $self, $num ) = @_;

    my $decimal_places = $self->{decimal_places};
    my $value          = $self->{value};
    my $new_value;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ($new_value) = _parse_num( $num, $decimal_places );
    }

    else {
        $new_value =
            $decimal_places == $num->{decimal_places}
          ? $num->{value}
          : _coerce( $num->{value}, $num->{decimal_places}, $decimal_places );
    }

    $self->{value} -= $new_value;
    return $self;
}

sub _division {
    my ( $self, $num, $reverse ) = @_;

    my $decimal_places = $self->{decimal_places};
    my $value          = $self->{value};
    my $another_value;
    my $another_decimal_places;

    if ( ref $num ne 'Math::FixedPoint' ) {
        $another_value          = $num;
        $another_decimal_places = 0;
    }

    else {
        $another_value          = $num->{value};
        $another_decimal_places = $num->{decimal_places};
    }

    croak 'Illegal division by zero' if $another_value == 0;

    my $result = $reverse ? $another_value / $value : $value / $another_value;
    my ( $new_value, $new_decimal_places ) = _parse_num($result);

    my $extra_decimal_places =
        $reverse
      ? $another_decimal_places - $decimal_places
      : $decimal_places - $another_decimal_places;

    $new_value =
      _coerce( $new_value, $new_decimal_places + $extra_decimal_places,
        $decimal_places );

    my $new = Math::FixedPoint->new;
    $new->{value}          = $new_value;
    $new->{decimal_places} = $decimal_places;
    return $new;
}

sub _division_inplace {
    my ( $self, $num, $reverse ) = @_;

    my $decimal_places = $self->{decimal_places};
    my $value          = $self->{value};
    my $another_value;
    my $another_decimal_places;

    if ( ref $num ne 'Math::FixedPoint' ) {
        $another_value          = $num;
        $another_decimal_places = 0;
    }

    else {
        $another_value          = $num->{value};
        $another_decimal_places = $num->{decimal_places};
    }

    croak 'Illegal division by zero' if $another_value == 0;

    my $result = $reverse ? $another_value / $value : $value / $another_value;
    my ( $new_value, $new_decimal_places ) = _parse_num($result);

    my $extra_decimal_places =
        $reverse
      ? $another_decimal_places - $decimal_places
      : $decimal_places - $another_decimal_places;

    $new_value =
      _coerce( $new_value, $new_decimal_places + $extra_decimal_places,
        $decimal_places );

    $self->{value} = $new_value;
    return $self;
}

sub _stringify {
    my $self = shift;

    my $value          = $self->{value};
    my $decimal_places = $self->{decimal_places};
    my $length         = length($value);

    return '0' if $value == 0 and $decimal_places == 0;

    my $decimal = $decimal_places ? substr( $value, -$decimal_places ) : '';
    my $integer = substr( $value, 0, -$decimal_places );
    return "$integer.$decimal";
}

sub _intify {
    my $self = shift;

    my $value          = $self->{value};
    my $decimal_places = $self->{decimal_places};

    return $value if $decimal_places == 0;

    my $new_value = substr $value, 0, -$decimal_places;
    return '0' if $new_value == 0;
    return $new_value;
}

1;
