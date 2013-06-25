[![Build Status](https://travis-ci.org/bluescreen10/Math-FixedPoint.png)](https://travis-ci.org/bluescreen10/Math-FixedPoint)

# NAME

Math::FixedPoint

# VERSION

version 0.20130625.2152

# SYNOPSIS

    use Math::FixedPoint;

    my $num = Math::FixedPoint->new(1.23);
    $num += 3.1234; # $num = 4.35

    # you can specifying the radix in the constructor

    my $num = Math::FixedPoint->new(1.23,3);
    $num += 3.1234; # $num = 4.353

# DESCRIPTION

This module implements fixed point arithmetic for Perl. There are applications, such as currency/money handling, where floating point numbers are not the best fit due to it's limited precision.

    $ perl -e 'print int(37.73*100)'
    3772

This problem is unacceptable in some applications. Some of those cases are better handled using fixed point math as precision is determined by the number of decimal places. To circumvent inherit problems with floating point numbers Math::BigFloat module is typically used, still problem exist, but precision is improved.

Now the problem with Math::BigFloat is that it is 3 or more orders of magnitude slower than Perl's floating point numbers, Math::FixedPoint on the other hand is 2 orders of magnitude slower than Perl's native numbers which is a huge gain over Math::BigFloat. That performance boost comes from the fact that most of the math is done internally using integer arithmetic.

# NAME

Math::FixedPoint - fixed-point arithmetic for Perl

# VERSION

version 0.20130625.2152

# METHODS

## new(`$number`, \[`$radix`\])

Creates a new object representing the `$number` provided. If `$radix` is not specified it will use the `$number`'s radix. If `$radix` is provided number will be rounded to the specified decimal places

# IMPLEMENTED OPERATIONS

The following operations are implemented by Math::FixedPoint are __\+__, __\+=__, __\-__, __\-=__, __\*__, __\*=__, __/__, __/=__, __=__, __<=__\>, __cmp__, __""__, __int__, __abs__

# CAVEATS & GOTCHAS

This module still ALPHA, feedback and patches are welcome.

## NUMBERS WITH DIFFERENT RADIX

It is not intuitive what it is going to happen when two numbers with different radix are used together

    my $num1 = Math::FixedPoint->new(1.23,2);
    my $num2 = Math::FixedPoint->new(1.234,3);

    my $res = $num1 + $num2;
    # $res = 2.46

    my $res = $num2 + $num1;
    # $res = 2.464

Due to the way that Perl handles overloaded methods, it will call the "add" method on the first object and will pass the second object as parameter. The "add" method will preserve the radix of the first object

## INTEGRATING WITH OTHER NUMBER CLASSES

Due to similar reasons when combining different classes it is not obvious which will be the class of the result object

    my $num1 = Math::FixedPoint->new(1.23);
    my $num2 = Math::BigFloat->new(1.24);

    my $res = $num1 + $num2;
    # ref $res = 'Math::FixedPoint'

    my $res = $num2 + $num1;
    # ref $res = 'Math::BigFloat'

It's critically important to have this in mind to prevent surprises

# PERFORMANCE

Although this module is implemented in pure Perl, it is still 5-10 times faster than Math::BigFloat (even more depending on Math::BigInt's backed).

# SEE ALSO

[Math::BigInt](http://search.cpan.org/perldoc?Math::BigInt), [Math::BigFloat](http://search.cpan.org/perldoc?Math::BigFloat)

# AUTHOR

Mariano Wahlmann <dichoso \_at\_ gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Mariano Wahlmann.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
