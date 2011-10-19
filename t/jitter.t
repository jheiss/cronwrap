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
isnt($?, 0, '--jitter requires an argument');
$number_of_tests_run++;

#
# Ensure that the argument must be a positive integer
#

system('./cronwrap --jitter bogus true > /dev/null 2>&1');
isnt($?, 0, '--jitter rejects string');
$number_of_tests_run++;
system('./cronwrap --jitter 0 true > /dev/null 2>&1');
isnt($?, 0, '--jitter rejects 0');
$number_of_tests_run++;
system('./cronwrap --jitter -1 true > /dev/null 2>&1');
isnt($?, 0, '--jitter rejects -1');
$number_of_tests_run++;

#
# I actually don't know how to test that the job was delayed, as some machines
# are going to have a jitter value very close to zero.
#

#
# However, we do expect the jitter to be consistent on any given machine. That
# we can test.  One minute (--jitter 1) is good enough for testing as cronwrap
# actually sleeps for a random number of seconds, so even with one minute of
# jitter cronwrap will sleep anywhere from 0-59 seconds.
#

# Time one run
my $start = time;
system('./cronwrap --jitter 1 true');
my $end = time;

my $elapsed = $end - $start;

# Now verify that a few more runs are within one second of the same delay
foreach (1, 2)
{
  my $start = time;
  system('./cronwrap --jitter 1 true');
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

