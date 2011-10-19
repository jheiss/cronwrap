#!/usr/bin/env perl

#
# Test the overlap prevention feature
#

use strict;
use warnings;
use Test::More;
use File::Temp;
use IPC::Open3;
my $number_of_tests_run = 0;

# Ensure job runs when no overlap condition exists
my $tmp = File::Temp->new();
system('./cronwrap', '--overlap', '--', 'sh', '-c', "echo test > $tmp");
open(my $nolapfh, '<', $tmp);
my $nolap = <$nolapfh>;
chomp($nolap);
close($nolapfh);
is($nolap, 'test', 'no overlap condition exists');
$number_of_tests_run++;

# Ensure job does not run when an overlap condition exists
my $pid = fork;
if ($pid)
{
  # Parent
  
  # Give the child a chance to start its copy of the job
  sleep 1;
  
  # Run the command and capture its output
  my ($wtr, $rdr);
  my $cmdpid = open3($wtr, $rdr, undef, './cronwrap --overlap sleep 3');
  # We don't have any input to send to the job
  close $wtr;
  my $output = do { local $/;  <$rdr> };
  waitpid($cmdpid, 0);
  my $exitvalue = $?>>8;
  
  isnt($exitvalue, 0, 'overlap condition exists, exit value');
  $number_of_tests_run++;
  is($output, "Job is already running\n", 'overlap condition exists, output');
  $number_of_tests_run++;
  
  waitpid($pid, 0);
}
else
{
  # Child
  system('./cronwrap --overlap sleep 3');
  exit;
}

done_testing($number_of_tests_run);

