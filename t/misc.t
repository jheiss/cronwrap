#!/usr/bin/env perl

#
# Test misc features of cronwrap
#

use strict;
use warnings;
use Test::More;
my $number_of_tests_run = 0;

#
# Test --help
#

open(my $helpfh, '-|', './cronwrap --help');
my @help = <$helpfh>;
close($helpfh);

# Make sure at least something resembling help output is there
ok(grep(/^Usage:/, @help), 'help output content');
$number_of_tests_run++;

# Make sure it fits on the screen
my $longest_help_line = 0;
foreach my $helpline (@help)
{
  if (length($helpline) > $longest_help_line)
  {
    $longest_help_line = length($helpline);
  }
}
ok($longest_help_line <= 80, 'help output columns');
$number_of_tests_run++;

ok(scalar(@help) <= 23, 'help output lines');
$number_of_tests_run++;

done_testing($number_of_tests_run);

