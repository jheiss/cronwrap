#!/usr/bin/env perl

#
# Test the nice feature
#

use strict;
use warnings;
use Test::More;
my $number_of_tests_run = 0;

#
# Ensure that --nice requires an argument
#

system('./cronwrap --nice > /dev/null 2>&1');
isnt($?, 0, '--nice requires an argument');
$number_of_tests_run++;

#
# Ensure that the argument must be an integer
#

system('./cronwrap --nice bogus true > /dev/null 2>&1');
isnt($?, 0, '--nice rejects string');
$number_of_tests_run++;
system('./cronwrap --nice bogus 1.0 > /dev/null 2>&1');
isnt($?, 0, '--nice rejects 1.0');
$number_of_tests_run++;
system('./cronwrap --nice bogus 1.5 > /dev/null 2>&1');
isnt($?, 0, '--nice rejects 1.5');
$number_of_tests_run++;

#
# Running as a regular user requesting a negative priority should fail
#

system('./cronwrap --nice -1 true > /dev/null 2>&1');
isnt($?, 0, '--nice -1 fails');
$number_of_tests_run++;

#
# Priority 0 should work
#

system('./cronwrap --nice 0 true > /dev/null 2>&1');
is($?, 0, '--nice 0 succeeds');
$number_of_tests_run++;
verify_priority(0);

#
# As should any positive integer up to around 19 or 20 depending on the
# operating system
#


system('./cronwrap --nice 1 true > /dev/null 2>&1');
is($?, 0, '--nice 1 succeeds');
$number_of_tests_run++;
verify_priority(1);
system('./cronwrap --nice 10 true > /dev/null 2>&1');
is($?, 0, '--nice 10 succeeds');
$number_of_tests_run++;
verify_priority(10);

#
# All done
#

done_testing($number_of_tests_run);

#
# Subroutines
#

sub verify_priority
{
  my $priority = shift;
  
  my $pid = fork;
  if ($pid)
  {
    # Parent
    
    # Give the child a chance to start the job
    sleep 1;
    
    # Check the process priority
    # 0==PRIO_PROCESS, apparently not defined in any core Perl library
    my $prio = getpriority(0, $pid);
    is($prio, $priority, "--nice $priority has right priority");
    $number_of_tests_run++;
    
    waitpid($pid, 0);
  }
  else
  {
    # Child
    exec("./cronwrap --nice $priority sleep 3");
  }
}

