use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

{
    my $num      = '1.23';
    my $instance = Math::FixedPoint->new($num);
    is int($instance), 1, "intify $num";
}

{
    my $num      = '0e0';
    my $instance = Math::FixedPoint->new($num);
    is int($instance), 0, "intify $num";
}

{
    my $num = '1.236';
    my $instance = Math::FixedPoint->new( $num, 2 );
    is int($instance), '1', "intify $num";
}

{
    my $num      = '-.27';
    my $instance = Math::FixedPoint->new($num);
    is int($instance), 0, "intify $num";
}

{
    my $num      = '-1.27';
    my $instance = Math::FixedPoint->new($num);
    is int($instance), -1, "intify $num";
}

{
    my $num = '0';
    my $instance = Math::FixedPoint->new( $num, 2 );
    is int($instance), 0, "intify $num";
}

{
    my $num = '1e6';
    my $instance = Math::FixedPoint->new( $num, 2 );
    is int($instance), 1000000, "intify $num";
}

done_testing();
