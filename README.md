# Overview #

This is a wrapper for cron jobs which implements common housekeeping tasks.

- Failure suppression
- Overlap protection
- Jitter
- Priority

# Failure Suppression #

If enabled cronwrap will suppress non-zero exit values and output unless the
job exceeds the specified number of consecutive failures. This is useful for
jobs that might fail occasionally due to extenuating circumstances but for
which the occasional failure is not a big deal as long as it the job starts
running successfully again soon.

# Overlap Protection #

If enabled cronwrap will not start multiple simultaneous copies of job. For
example, you have a job that runs once an hour and usually completes in a
minute. However, there's a chance it will get stuck and take more than an hour
or even hang forever. You might not want cron to start another copy of the job
while the previous job is still running.

# Jitter #

If enabled cronwrap will delay for a random amount of time up to a specified
maximum before starting the job. This is useful for jobs that run on many
machines but access a centralized service.

# Priority #

Set the priority, aka "nice" the job.

