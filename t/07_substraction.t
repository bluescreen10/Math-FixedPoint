use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

{
    my $num1      = '1.23';
    my $num2      = '2.44';
    my $instance1 = Math::FixedPoint->new($num1);
    my $instance2 = Math::FixedPoint->new($num2);

    my $result = $instance1 - $instance2;
    is $result->value,          '-121', "$num1 - $num2 - value";
    is $result->decimal_places, 2,      "$num1 - $num2 - decimal places ";
}

{
    my $num1      = '1.23';
    my $num2      = 2;
    my $instance1 = Math::FixedPoint->new($num1);

    my $result = $instance1 - $num2;
    is $result->value,          '-77', "$num1 - $num2 - value";
    is $result->decimal_places, 2,     "$num1 - $num2 - decimal places ";
}

{
    my $num1      = 1;
    my $num2      = '1.23';
    my $instance1 = Math::FixedPoint->new($num2);

    my $result = $num1 - $instance1;
    is $result->value,          '-23', "$num1 - $num2 - value";
    is $result->decimal_places, 2,     "$num1 - $num2 - decimal places ";
}

{
    my $num1      = '1.23';
    my $num2      = 1;
    my $instance1 = Math::FixedPoint->new($num1);

    my $result = $instance1 - $num2;
    is $result->value,          '23', "$num1 - $num2 - value";
    is $result->decimal_places, 2,    "$num1 - $num2 - decimal places ";
}

{
    my $num1      = -1;
    my $num2      = '1.23';
    my $instance1 = Math::FixedPoint->new($num2);

    my $result = $num1 - $instance1;
    is $result->value,          '-223', "$num1 - $num2 - value";
    is $result->decimal_places, 2,      "$num1 - $num2 - decimal places ";
}

done_testing();
