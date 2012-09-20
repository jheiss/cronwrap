#!/usr/bin/env perl

#
# Test the timeout feature
#

use strict;
use warnings;
use Test::More;
my $number_of_tests_run = 0;
use File::Temp qw(tempfile);

#
# Ensure that --timeout requires an argument
#

system('./cronwrap --timeout > /dev/null 2>&1');
isnt($?>>8, 0, '--timeout requires an argument');
$number_of_tests_run++;

#
# Ensure that the argument must be a time delta
#
# It would be nice to unit test the parse_time_delta subroutine, but I don't
# know how to do that without moving it to a library file, which would
# complicate installation for users.  I like the simplicity of having cronwrap
# be a single, standalone executable.
#

system('./cronwrap --timeout bogus true > /dev/null 2>&1');
isnt($?>>8, 0, '--timeout rejects string');
$number_of_tests_run++;
system('./cronwrap --timeout 0 true > /dev/null 2>&1');
isnt($?>>8, 0, '--timeout rejects 0');
$number_of_tests_run++;
system('./cronwrap --timeout -1 true > /dev/null 2>&1');
isnt($?>>8, 0, '--timeout rejects -1');
$number_of_tests_run++;
system('./cronwrap --timeout 1r true > /dev/null 2>&1');
isnt($?>>8, 0, '--timeout rejects 1r');
$number_of_tests_run++;

system('./cronwrap --timeout 1s true > /dev/null 2>&1');
is($?>>8, 0, '--timeout accepts 1s');
$number_of_tests_run++;
system('./cronwrap --timeout 1m true > /dev/null 2>&1');
is($?>>8, 0, '--timeout accepts 1m');
$number_of_tests_run++;
system('./cronwrap --timeout 1h true > /dev/null 2>&1');
is($?>>8, 0, '--timeout accepts 1h');
$number_of_tests_run++;
system('./cronwrap --timeout 1d true > /dev/null 2>&1');
is($?>>8, 0, '--timeout accepts 1d');
$number_of_tests_run++;
system('./cronwrap --timeout 1w true > /dev/null 2>&1');
is($?>>8, 0, '--timeout accepts 1w');
$number_of_tests_run++;
system('./cronwrap --timeout 1mo true > /dev/null 2>&1');
is($?>>8, 0, '--timeout accepts 1mo');
$number_of_tests_run++;
system('./cronwrap --timeout 1y true > /dev/null 2>&1');
is($?>>8, 0, '--timeout accepts 1y');
$number_of_tests_run++;

#
# A job that runs less than the timeout should run to completion
#

my $start = time;
system('./cronwrap --timeout 30s sleep 5 > /dev/null 2>&1');
my $end = time;
is($?>>8, 0, '--timeout 10 sleep 5');
$number_of_tests_run++;
my $elapsed = $end - $start;
cmp_ok($elapsed, '>=', 5);
$number_of_tests_run++;
cmp_ok($elapsed, '<=', 6);
$number_of_tests_run++;

#
# A job that runs longer than the timeout should be terminated
#

$start = time;
system('./cronwrap --timeout 5s sleep 30 > /dev/null 2>&1');
$end = time;
isnt($?>>8, 0, '--timeout 5 sleep 10');
$number_of_tests_run++;
$elapsed = $end - $start;
cmp_ok($elapsed, '>=', 5);
$number_of_tests_run++;
# This builds in a few seconds of fudge factor for system load, etc.
cmp_ok($elapsed, '<=', 10);
$number_of_tests_run++;

#
# A job that ignores SIGTERM should be killed by SIGKILL
#

my ($tempfh, $tempfile) = tempfile();
print $tempfh <<EOF;
#!/usr/bin/env perl
\$SIG{TERM} = 'IGNORE';
sleep 30;
EOF
close($tempfh);
chmod(0755, $tempfile);

$start = time;
system("./cronwrap --timeout 5s $tempfile > /dev/null 2>&1");
$end = time;
isnt($?>>8, 0, '--timeout 5 sigkill');
$number_of_tests_run++;
$elapsed = $end - $start;
# 5 seconds of timeout, plus cronwrap's 5 second wait before using SIGKILL
cmp_ok($elapsed, '>=', 10);
$number_of_tests_run++;
# Plus a few more seconds of fudge factor for system load, etc.
cmp_ok($elapsed, '<=', 15);
$number_of_tests_run++;

#
# All done
#

done_testing($number_of_tests_run);

