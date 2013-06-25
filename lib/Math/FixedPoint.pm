package Math::FixedPoint;
use strict;
use warnings;
use Carp qw(croak);
use overload
  '+'      => \&_add,
  '-'      => \&_substract,
  '*'      => \&_multiply,
  '/'      => \&_division,
  '='      => \&_copy,
  '""'     => \&_stringify,
  'int'    => \&_intify,
  'abs'    => \&_absify,
  fallback => 1;

sub new {
    my ( $class, $num, $precision ) = @_;

    my $self;

    if ( defined $num ) {
        my @values = _parse_num( $num, $precision );

        $self = \@values;
    }

    else {
        $self = [ 0, 0, 1 ];
    }

    bless $self, $class;
}

sub _parse_num {
    my ( $str, $precision ) = @_;

    if ( int($str) eq $str ) {
        my $value = abs($str);
        my $sign = $str < 0 ? -1 : 1;

        return
          defined $precision
          ? ( $sign, $value * 10**$precision, $precision )
          : ( $sign, $value, 0 );
    }

    elsif ( $str =~ /^  ([-+]?)(\d*)  (?:\.(\d+))?  (?:[eE]([-+]?\d+))?  $/x ) {

        my $sign = defined $1 && $1 eq '-' ? -1 : 1;
        my $num     = $2 || 0;
        my $decimal = $3 || '';
        my $exp     = $4 || 0;

        my $radix = length($decimal);
        $radix -= $exp;

        my $value =
            $radix < 0
          ? $num . $decimal . ( '0' x -$radix )
          : $num . $decimal;

        $radix = 0 if $radix < 0;

        return
          defined $precision
          ? ( $sign, int _coerce( $value, $radix, $precision ), $precision )
          : ( $sign, int $value, $radix );
    }
    else {
        croak "$str not a valid number";
    }
}

sub _coerce {
    my ( $num, $radix, $precision ) = @_;

    return $num if $radix == $precision;

    if ( $precision >= $radix ) {
        return $num * 10**( $precision - $radix );
    }

    else {
        my $places   = $precision - $radix;
        my $reminder = substr( $num, $places );
        my $new_num  = substr( $num, 0, $places );

        $new_num++ if $reminder > 5 * 10**( -1 * $places - 1 );

        return $new_num;
    }
}

sub _copy {
    my $self = shift;
    my $new  = Math::FixedPoint->new;

    $new->[0] = $self->[0];
    $new->[1] = $self->[1];
    $new->[2] = $self->[2];

    return $new;
}

sub _add {
    my ( $self, $num ) = @_;

    my $radix = $self->[2];
    my $value = $self->[1];
    my $sign  = $self->[0];

    my $new_sign;
    my $new_value;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ( $new_sign, $new_value ) = _parse_num( $num, $radix );
    }

    else {
        $new_sign = $num->[0];
        $new_value = _coerce( $num->[1], $num->[2], $radix );
    }

    my $signed_result   = $new_sign * $new_value + $sign * $value;
    my $unsigned_result = abs($signed_result);

    my $new = Math::FixedPoint->new;
    $new->[0] = $signed_result < 0 ? -1 : 1;
    $new->[1] = $unsigned_result;
    $new->[2] = $radix;

    return $new;
}

sub _substract {
    my ( $self, $num, $reverse ) = @_;

    my $sign  = $self->[0];
    my $value = $self->[1];
    my $radix = $self->[2];

    my $new_sign;
    my $new_value;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ( $new_sign, $new_value ) = _parse_num( $num, $radix );
    }

    else {
        $new_sign = $num->[0];
        $new_value = _coerce( $num->[1], $num->[2], $radix );
    }

    $new_sign = $reverse ? $new_sign  : -1 * $new_sign;
    $sign     = $reverse ? -1 * $sign : $sign;

    my $signed_result   = $new_sign * $new_value + $sign * $value;
    my $unsigned_result = abs($signed_result);

    my $new = Math::FixedPoint->new;
    $new->[0] = $signed_result < 0 ? -1 : 1;
    $new->[1] = $unsigned_result;
    $new->[2] = $radix;

    return $new;
}

sub _multiply {
    my ( $self, $num ) = @_;

    my $sign  = $self->[0];
    my $value = $self->[1];
    my $radix = $self->[2];

    my $new_sign;
    my $new_value;
    my $new_radix;

    if ( ref $num ne 'Math::FixedPoint' ) {
        ( $new_sign, $new_value, $new_radix ) = _parse_num($num);

        $new_value =
          _coerce( $value * $new_value, $new_radix + $radix, $radix );
    }
    else {
        $new_sign = $num->[0];
        $new_value = _coerce( $value * $num->[1], $radix + $num->[2], $radix );
    }

    my $new = Math::FixedPoint->new;

    $new->[0] = $sign * $new_sign;
    $new->[1] = $new_value;
    $new->[2] = $radix;

    return $new;
}

sub _division {
    my ( $self, $num, $reverse ) = @_;

    my $sign  = $self->[0];
    my $value = $self->[1];
    my $radix = $self->[2];

    my $another_sign;
    my $another_value;
    my $another_radix;

    if ( ref $num ne 'Math::FixedPoint' ) {
        $another_sign  = $num < 0 ? -1 : 1;
        $another_value = abs($num);
        $another_radix = 0;
    }

    else {
        $another_sign  = $num->[0];
        $another_value = $num->[1];
        $another_radix = $num->[2];
    }

    croak 'Illegal division by zero' if $another_value == 0;

    my $result = $reverse ? $another_value / $value : $value / $another_value;
    my ( $new_sign, $new_value, $new_radix ) = _parse_num($result);

    my $extra_radix =
        $reverse
      ? $another_radix - $radix
      : $radix - $another_radix;

    $new_value = _coerce( $new_value, $new_radix + $extra_radix, $radix );

    my $new = Math::FixedPoint->new;

    $new->[0] = $sign * $another_sign;
    $new->[1] = $new_value;
    $new->[2] = $radix;

    return $new;
}

sub _stringify {
    my $self = shift;

    my $sign  = $self->[0] < 0 ? '-' : '';
    my $value = $self->[1];
    my $radix = $self->[2];

    return "$sign$value" if $radix == 0;

    my $length = length($value);
    return sprintf( "${sign}0.%0${radix}d", $value ) if $length <= $radix;

    my $decimal = substr( $value, -$radix );
    my $integer = substr( $value, 0, -$radix );
    return "$sign$integer.$decimal";
}

sub _intify {
    my $self = shift;

    my $sign  = $self->[0];
    my $value = $self->[1];
    my $radix = $self->[2];

    my $new = Math::FixedPoint->new;
    $new->[2] = 0;

    if ( $radix == 0 ) {
        $new->[0] = $sign;
        $new->[1] = $value;
    }

    else {
        my $new_value = substr $value, 0, -$radix;
        $new_value ||= 0;
        $new->[0] = $new_value == 0 ? 1 : $sign;
        $new->[1] = $new_value;
    }

    return $new;
}

sub _absify {
    my $self = shift;

    my $sign  = $self->[0];
    my $value = $self->[1];
    my $radix = $self->[2];

    my $new = Math::FixedPoint->new;
    $new->[0] = 1;
    $new->[1] = $value;
    $new->[2] = $radix;
    
    return $new;
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

=head2 new(C<$number>, [C<$radix>])

Creates a new object representing the C<$number> provided. If C<$radix> is not specified it will use the decimal places provided by the C<$number>. If C<$radix> is provided number will be rounded to the specified decimal places

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
