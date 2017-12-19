#!/bin/sh
# check every hours
# echo '0 */1 * * *    /bin/run.sh' > /var/spool/cron/crontabs/root
cp /dev/null /var/spool/cron/crontabs/root
# search in containers for our labels (in all states)
for dockerContainer in $(docker ps -aq)
do
   jsonOut=$(docker inspect --format "{{ index .Config.Labels \"com.businessdecisision.cron_handler_configuration\"}}" $dockerContainer)
   for ROWCRON in "$(echo $jsonOut | jq -r '.[]')"; do
     echo "${ROWCRON}" | jq -r .cmd >> /var/spool/cron/crontabs/root
	 sed -i -e "s/cont-id-to-cron/${dockerContainer}/g" /var/spool/cron/crontabs/root
   done
done
