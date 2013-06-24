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

sub value          { $_[0]->{value} }
sub decimal_places { $_[0]->{decimal_places} }

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
__END__

=head1 NAME

Math::FixedPoint - fixed-point arithmetic for Perl

=head1 SYNOPSIS

    use Math::FixedPoint;

    my $num = Math::FixedPoint->new(1.23);
    $num += 3.1234; # $num = 4.35

    # you can specifying the precision in the constructor

    my $num = Math::FixedPoint->new(1.23,3);
    $num += 3.1234; # $num = 4.353


=head1 DESCRIPTION

This module implements fixed point arithmetic for Perl. There are applications, such as currency/money handling, where floating point numbers are not the best fit due to it's limited precision.

   $ perl -e 'print int(37.73*100)'
   3772

This problem is unacceptable in some applications. Some of those cases are better handled using fixed point math as precision is determined by the number of decimal places. To circumvent inherit problems with floating point numbers Math::BigFloat module is typically used, still problem exist, but precision is improved.

Now the problem with Math::BigFloat is that it is 3 or more orders of magnitude slower than Perl's float numbers, Math::FixedPoint on the other hand is 2 orders of magnitude slower than Perl's native numbers which is a huge gain over Math::BigFloat. That performance boost comes from the fact that most of the math is done internally using integer arithmetic.

=head1 METHODS

=head2 new(C<$number>, [C<$decimal_places>])

Creates a new object representing the C<$number> provided. If C<$decimal_places> is not specified it will use the decimal places provided by the C<$number>. If C<$decimal_places> is provided number will be rounded to the specified decimal places

=head2 value

Return the integer that represent the number

    my $num = Math::FixedPoint->new(1.23);
    print "value:".$num->value;
    # value:123

=head2 decimal_places

Return the position of the decimal place separator

    my $num = Math::FixedPoint->new(1.23);
    print "value:".$num->decimal_places;
    # value: 2

=head1 IMPLEMENTED OPERATIONS

The following operations are implemented by Math::FixedPoint are B<+>,B<+=>,B<->,B<-=>,B<*>,B<*=>,B</>,B</=>,B<=>,B<""> and B<int>

=head1 CAVEATS & GOTCHAS

This module still ALPHA, feedback and patches are welcome.

=head2 NUMBERS WITH DIFFERENT PRECISION

It is not intuitive what it is going to happen when two numbers with different precision are used together

    my $num1 = Math::FixedPoint->new(1.23,2);
    my $num2 = Math::FixedPoint->new(1.234,3);

    my $res = $num1 + $num2;
    # $res = 2.46

    my $res = $num2 + $num1;
    # $res = 2.464
  
Due to the way that Perl handles overloaded methods, it will call the "add" method on the first object and will pass the second object as parameter. The "add" method will preserve the precision of the first object

=head2 NUMBERS FROM DIFFERENT CLASSES

Due to similar reasons when combining different classes it is not obvious which will be the class of the result object

    my $num1 = Math::FixedPoint->new(1.23);
    my $num2 = Math::BigFloat->new(1.24);

    my $res = $num1 + $num2;
    # ref $res = 'Math::FixedPoint'

    my $res = $num2 + $num1;
    # ref $res = 'Math::BigFloat'

It's critically important to have this in mind to prevent surprises

=head1 PERFORMANCE

Although this module is implemented in pure Perl, it is still 5-10 times faster than Math::BigFloat (even more depending on Math::BigInt's backed).

=head1 SEE ALSO

L<Math::BigInt>, L<Math::BigFloat>

=cut

