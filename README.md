# Redis-Sentinel-Backup
Master Backup your's Redis sentinel from any redis sentinel cluster.
Backup is stored in S3 bucket.
Script also has integration with slack channel where swe can gate realtime update.
You can create the cron to manage the script regularly.

# Script entry on Crontab 

0 2 * * * /bin/bash <path to script>/redis_backup.sh  >> <path to log> redis_backup.log 

In above crontab entry backup is created at 2:00 am every night. Change the value as per your requirment.
