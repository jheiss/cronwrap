#!/usr/bin/env perl

#
# Test the jitter feature
#

use strict;
use warnings;
use Test::More;
my $number_of_tests_run = 0;

#
# Ensure that --jitter requires an argument
#

system('./cronwrap --jitter > /dev/null 2>&1');
isnt($?>>8, 0, '--jitter requires an argument');
$number_of_tests_run++;

#
# Ensure that the argument must be a time delta
#
# It would be nice to unit test the parse_time_delta subroutine, but I don't
# know how to do that without moving it to a library file, which would
# complicate installation for users.  I like the simplicity of having cronwrap
# be a single, standalone executable.
#

system('./cronwrap --jitter bogus true > /dev/null 2>&1');
isnt($?>>8, 0, '--jitter rejects string');
$number_of_tests_run++;
system('./cronwrap --jitter 0 true > /dev/null 2>&1');
isnt($?>>8, 0, '--jitter rejects 0');
$number_of_tests_run++;
system('./cronwrap --jitter -1 true > /dev/null 2>&1');
isnt($?>>8, 0, '--jitter rejects -1');
$number_of_tests_run++;
system('./cronwrap --jitter 1r true > /dev/null 2>&1');
isnt($?>>8, 0, '--jitter rejects 1r');
$number_of_tests_run++;

system('./cronwrap --jitter 1 true > /dev/null 2>&1');
is($?>>8, 0, '--jitter accepts 1');
$number_of_tests_run++;
system('./cronwrap --jitter 1s true > /dev/null 2>&1');
is($?>>8, 0, '--jitter accepts 1s');
$number_of_tests_run++;
system('./cronwrap --jitter 1m true > /dev/null 2>&1');
is($?>>8, 0, '--jitter accepts 1m');
$number_of_tests_run++;
# system('./cronwrap --jitter 1h true > /dev/null 2>&1');
# is($?>>8, 0, '--jitter accepts 1h');
# $number_of_tests_run++;
# system('./cronwrap --jitter 1d true > /dev/null 2>&1');
# is($?>>8, 0, '--jitter accepts 1d');
# $number_of_tests_run++;
# system('./cronwrap --jitter 1w true > /dev/null 2>&1');
# is($?>>8, 0, '--jitter accepts 1w');
# $number_of_tests_run++;
# system('./cronwrap --jitter 1mo true > /dev/null 2>&1');
# is($?>>8, 0, '--jitter accepts 1mo');
# $number_of_tests_run++;
# system('./cronwrap --jitter 1y true > /dev/null 2>&1');
# is($?>>8, 0, '--jitter accepts 1y');
# $number_of_tests_run++;

#
# I actually don't know how to test that the job was delayed, as some machines
# are going to have a jitter value very close to zero.
#

#
# However, we do expect the jitter to be consistent on any given machine. That
# we can test.  One minute (--jitter 1m) is good enough for testing as cronwrap
# actually sleeps for a random number of seconds, so even with one minute of
# jitter cronwrap will sleep anywhere from 0-59 seconds.
#

# Time one run
my $start = time;
system('./cronwrap --jitter 1m true');
my $end = time;

my $elapsed = $end - $start;

# Now verify that a few more runs are within one second of the same delay
foreach (1, 2)
{
  my $start = time;
  system('./cronwrap --jitter 1m true');
  my $end = time;
  
  my $test_elapsed = $end - $start;
  cmp_ok($test_elapsed, '<=', $elapsed+1);
  $number_of_tests_run++;
  cmp_ok($test_elapsed, '>=', $elapsed-1);
  $number_of_tests_run++;
}

#
# All done
#

done_testing($number_of_tests_run);

