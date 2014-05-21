# Overview #

This is a wrapper for cron jobs which implements common housekeeping tasks.

- Jitter
- Overlap protection
- Timeout
- Failure suppression
- Priority

# Jitter #

If enabled cronwrap will delay for a random amount of time up to a specified
maximum before starting the job. This is useful for jobs that run on many
machines but access a centralized service. The random number generator is
seeded with the hostname of the machine so that the job runs at a consistent
time on each machine.

    cronwrap --jitter 5m <job>

# Overlap Protection #

If enabled cronwrap will not start multiple simultaneous copies of job. For
example, you have a job that runs once an hour and usually completes in a
minute. However, there's a chance it will get stuck and take more than an hour
or even hang forever. You might not want cron to start another copy of the job
while the previous job is still running.

    cronwrap --overlap <job>

# Timeout #

If enabled cronwrap will terminate the process if it runs longer than the
specified timeout.  A SIGTERM will be sent to the job followed by a SIGKILL
after 5 seconds.

    cronwrap --timeout 1h <job>

# Priority #

Set process priority similar to the Unix utility _nice_

    cronwrap --nice 19 <job>

# Failure Suppression #

If enabled cronwrap will suppress non-zero exit values and output unless the
job exceeds the specified number of consecutive failures. This is useful for
jobs that might fail occasionally due to extenuating circumstances but for
which the occasional failure is acceptable as long as it the job starts
running successfully again soon.

    cronwrap --suppress 3 <job>

# Downloads #

Tarballs available from the
[tags](https://github.com/jheiss/cronwrap/tags) page.
