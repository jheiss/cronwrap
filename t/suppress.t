#!/usr/bin/env perl

#
# Test the failure suppression feature
#

use strict;
use warnings;
use Test::More;
use File::Temp;
use IPC::Open3;
my $number_of_tests_run = 0;

my $suppresstmp = File::Temp->new();

#
# Ensure that --suppress requires an argument
#

system('./cronwrap --suppress > /dev/null 2>&1');
isnt($?>>8, 0, '--suppress requires an argument');
$number_of_tests_run++;

#
# Ensure that the argument must be a positive integer
#

system('./cronwrap --suppress bogus true > /dev/null 2>&1');
isnt($?>>8, 0, '--suppress rejects string');
$number_of_tests_run++;
system('./cronwrap --suppress 0 true > /dev/null 2>&1');
isnt($?>>8, 0, '--suppress rejects 0');
$number_of_tests_run++;
system('./cronwrap --suppress -1 true > /dev/null 2>&1');
isnt($?>>8, 0, '--suppress rejects -1');
$number_of_tests_run++;

#
# Success not suppressed without --suppress
#

seek($suppresstmp, 0, SEEK_SET);
print $suppresstmp "succeed\n";
ensure_no_suppression_on_success($suppresstmp, 1);

#
# Failure not suppressed without --suppress
#

seek($suppresstmp, 0, SEEK_SET);
print $suppresstmp "fail\n";
ensure_no_suppression_on_failure($suppresstmp, 1);

#
# Have a successful run to reset the count
#

seek($suppresstmp, 0, SEEK_SET);
print $suppresstmp "succeed\n";
run_job($suppresstmp);

#
# Ensure that the appropriate number of failures are suppressed
#

seek($suppresstmp, 0, SEEK_SET);
print $suppresstmp "fail\n";
ensure_suppression($suppresstmp);
ensure_suppression($suppresstmp);
ensure_no_suppression_on_failure($suppresstmp);

#
# Fail another time to ensure it stays unsuppressed
#

ensure_no_suppression_on_failure($suppresstmp);

#
# Have the command succeed to ensure that we reset to suppression on success
#

seek($suppresstmp, 0, SEEK_SET);
print $suppresstmp "succeed\n";
ensure_suppression($suppresstmp);
ensure_suppression($suppresstmp);

#
# Switch back to failing and build up a couple of consecutive failures
#

seek($suppresstmp, 0, SEEK_SET);
print $suppresstmp "fail\n";
ensure_suppression($suppresstmp);
ensure_suppression($suppresstmp);

#
# Have a successful run to reset the count
#

seek($suppresstmp, 0, SEEK_SET);
print $suppresstmp "succeed\n";
ensure_suppression($suppresstmp);

#
# And now fail enough to trigger unsuppression
#

seek($suppresstmp, 0, SEEK_SET);
print $suppresstmp "fail\n";
ensure_suppression($suppresstmp);
ensure_suppression($suppresstmp);
ensure_no_suppression_on_failure($suppresstmp);
ensure_no_suppression_on_failure($suppresstmp);

#
# All done
#

done_testing($number_of_tests_run);

#
# Subroutines
#

sub ensure_suppression
{
  my ($output, $exitvalue) = run_job(@_);
  is($exitvalue, 0, '--suppress run, should be suppressed, exit value');
  $number_of_tests_run++;
  is($output, '', '--suppress run, should be suppressed, output');
  $number_of_tests_run++;
}

sub ensure_no_suppression_on_success
{
  my ($output, $exitvalue) = run_job(@_);
  is($exitvalue, 0, '--suppress run, success, should not be suppressed, exit value');
  $number_of_tests_run++;
  is($output, "tester is succeeding\n", '--suppress run, success, should not be suppressed, output');
  $number_of_tests_run++;
}
sub ensure_no_suppression_on_failure
{
  my ($output, $exitvalue) = run_job(@_);
  isnt($exitvalue, 0, '--suppress run, failure, should not be suppressed, exit value');
  $number_of_tests_run++;
  is($output, "tester is failing\n", '--suppress run, failure, should not be suppressed, output');
  $number_of_tests_run++;
}

sub run_job
{
  my $file = shift;
  my $omit_suppress = shift;
  
  my @cmd = ('./cronwrap', './t/tester', $file);
  unless ($omit_suppress) {
    push @cmd, '--suppress', '3';
  }
  
  my ($wtr, $rdr);
  my $pid = open3($wtr, $rdr, undef, @cmd);
  # We don't have any input to send to the job
  close $wtr;
  
  my $output = do { local $/;  <$rdr> };
  
  waitpid($pid, 0);
  my $exitvalue = $?>>8;
  
  return $output, $exitvalue;
}
