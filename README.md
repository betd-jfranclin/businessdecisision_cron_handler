# businessdecisision_cron_handler
---
##### A simple crontab handler with label reader based on gliderlabs/alpine:3.3
--
This image will write in a crontab file what other containers wants to be done.
A script search for a specific label on every docker containers which should contains a JSON string with crons to set.

## Configuration :

Each docker containers should have the label  "com.businessdecisision.cron_handler_configuration" setted.
This label will have a JSON string which will be an array of cron commands :

```javascript
[
    { 
        "cmd": "*/2 * * * * /bin/run.sh >> /var/log/myjob.log 2>&1"
    },
    { 
        "cmd": "* * * * * echo 'hello' >> /var/log/myjob2.log 2>&1"
    },
    { 
        "cmd": "* * 1 * * docker stop cont-id-to-cron >> /var/log/myjob2.log 2>&1"
    }
]
```

## How it works :

 - When building the image, a cron task is setted to run the script 2 minutes after first boot.
 - This task looks for every docker containers (in all states)  which have our label.
 - For every labels, the configuration is setted into the crontab file.
 - Cron tasks are executed programmatically.
 - The script replace the keyword 'cont-id-to-cron' with the docker container id which hold the label
 - By default, the container don't update the crontab file, only at first run.
   - To do so, put a label on the cron container with the frequence you need to update
 
## How to :

1. docker build ./conf --no-cache
2. docker run -v /var/run/docker.sock:/var/run/docker.sock -l <label>=<value>

 - You must create a label on the container to configure the frequence of refreshing the crontabs with other containers configuration.
 - The script is located in /bin/run.sh
 - Example : 
 ```
 # For a scan every hour :
com.businessdecisision.cron_handler_configuration: '[{"cmd":"* */1 * * * /bin/run.sh >> /var/log/myjob.log 2>&1"}]'
```

## Tricks

- Use the keyword 'cont-id-to-cron' in your json command to substitue with the target container's ID
- Set a cron label on the CRON container to programmatically scan other containers labels

# Docker compose :

```
version: '2'
services:
  businessdecisision_cron_handler:
    image: businessdecisision_cron_handler:v0.1
    container_name: businessdecisision_cron_handler
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      # fors logs
      - ./logs:/var/log/
    labels:
    # to scan other containers every 2 minutes
      com.businessdecisision.cron_handler_configuration: '[{"cmd":"*/2 * * * *    /bin/run.sh >> /var/log/myjob.log 2>&1"}]'
```
