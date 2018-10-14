#!/bin/bash
#author=akash agrawal
# We can run this script from any redis sentinel but backup will always be taken from MATER node.
role_cluster=$(redis-cli info | grep role |awk --field-separator=":" '{print $2}'| rev | cut -c 2- | rev | head --bytes -1) #find the role of cluster
master_ip=$(redis-cli info | grep master_host|awk --field-separator=":" '{print $2}'| rev | cut -c 2- | rev | head --bytes -1) #Find the mster IP
bucket_name=EnterYourBucketName
slackurl= https://hooks.slack.com/yourSlackToken #enter your slackurl
#echo $role_cluster
if [[ $role_cluster == "slave" ]]
then
        if [ ! -d "/backup/redis/" ]; then
  			mkdir /backup/
 			mkdir /backup/redis/
		fi
		#DIR=`cat /etc/redis/redis.conf |grep '^dir '|cut -d' ' -f2`
		redis-cli --rdb dump.rdb -h $master_ip
		cp /var/redis/dump.rdb /backup/redis/dump.$(date +%Y-%m-%d).rdb
		cd /backup/redis
		zip dump.$(date +%Y-%m-%d).zip dump.$(date +%Y-%m-%d).rdb
		aws s3 mv dump.$(date +%Y-%m-%d).zip s3://$bucket_name
		/usr/bin/curl -X POST --data-urlencode "payload={\"channel\": \"#channel_name\", \"text\": \"$(date +%Y-%m-%d) : Redis back completed and moved to S3 currently master node is $master_ip  \", \"icon_emoji\": \":sunglasses:\"}" $slackurl
		rm -rf dump.$(date +%Y-%m-%d).zip dump.$(date +%Y-%m-%d).rdb

else
        if [ ! -d "/backup/redis/" ]; then
  			mkdir /backup/
 			mkdir /backup/redis/
		fi
		#DIR=`cat /etc/redis/redis.conf |grep '^dir '|cut -d' ' -f2`
		redis-cli bgsave
		cp /var/redis/dump.rdb /backup/redis/dump.$(date +%Y-%m-%d).rdb
		cd /backup/redis
		zip dump.$(date +%Y-%m-%d).zip dump.$(date +%Y-%m-%d).rdb
		aws s3 mv dump.$(date +%Y-%m-%d).zip s3://$bucket_name
		/usr/bin/curl -X POST --data-urlencode "payload={\"channel\": \"#channel_name\", \"text\": \"$(date +%Y-%m-%d) : Redis back completed and moved to S3 currently master node is $master_ip  \", \"icon_emoji\": \":sunglasses:\"}" $slackurl
		rm -rf dump.$(date +%Y-%m-%d).zip dump.$(date +%Y-%m-%d).rdb


fi
