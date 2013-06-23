use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

{
    my $num = '1.23';
    my $fp  = Math::FixedPoint->new($num);
    is $fp->value,          '123', "$num - value";
    is $fp->decimal_places, 2,     "$num - decimal places";
}

{
    my $num = '123';
    my $fp  = Math::FixedPoint->new($num);
    is $fp->value,          '123', "$num - value";
    is $fp->decimal_places, 0,     "$num - decimal places";
}

{
    my $num = '.23';
    my $fp  = Math::FixedPoint->new($num);
    is $fp->value,          '23', "$num - value";
    is $fp->decimal_places, 2,    "$num - decimal places";
}

{
    my $num = '9.23e1';
    my $fp  = Math::FixedPoint->new($num);
    is $fp->value,          '923', "$num - value";
    is $fp->decimal_places, 1,     "$num - decimal places";
}

{
    my $num = '9.23e-1';
    my $fp  = Math::FixedPoint->new($num);
    is $fp->value,          '923', "$num - value";
    is $fp->decimal_places, 3,     "$num - decimal places";
}

{
    my $num = '-123e-2';
    my $fp  = Math::FixedPoint->new($num);
    is $fp->value,          '-123', "$num - value";
    is $fp->decimal_places, 2,      "$num - decimal places";
}

{
    my $num = '0.00';
    my $fp  = Math::FixedPoint->new($num);
    is $fp->value,          '00', "$num - value";
    is $fp->decimal_places, 2,    "$num - decimal places";
}

{
    my $num = '1.1243';
    my $fp = Math::FixedPoint->new( $num, 3 );
    is $fp->value,          '1124', "$num - value";
    is $fp->decimal_places, 3,      "$num - decimal places";
}

{
    my $num = '1.12451';
    my $fp = Math::FixedPoint->new( $num, 3 );
    is $fp->value,          '1125', "$num - value";
    is $fp->decimal_places, 3,      "$num - decimal places";
}

done_testing();
