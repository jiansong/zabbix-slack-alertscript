#!/bin/bash

# Slack incoming web-hook URL and user name
url='CHANGEME'		# example: https://hooks.slack.com/services/QW3R7Y/D34DC0D3/BCADFGabcDEF123
username='Zabbix'

# Values received by this script:
# To = $1 (Slack channel or user to send the message to, specified in the Zabbix web interface; "@username" or "#channel")
# Subject = $2 (usually either PROBLEM or RECOVERY)
# Message = $3 (whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")

# Get the Slack channel or user ($1) and Zabbix subject ($2 - hopefully either PROBLEM or RECOVERY)
to="$1"
subject="$2"
message="$3"

# Change message emoji depending on the subject - smile (RECOVERY), frowning (PROBLEM), or ghost (for everything else)
#recoversub='^RECOVER(Y|ED)?$'
#if [[ "$subject" =~ ${recoversub} ]]; then
#	emoji=':smile:'
#elif [ "$subject" == 'PROBLEM' ]; then
#	emoji=':frowning:'
#else
#	emoji=':ghost:'
#fi

if [[ $subject == *"RESOLVED"* ]]; then
    color="good"
elif [[ $subject == *"Acknowledged"* ]]; then
    color="#7499FF"
elif [[ $subject == *"OK"* ]]; then
    color="good"
else  
    case "$message" in 
        *"Not classified"* )
                color="#97AAB3"
                ;;
        *"Information"* )
                color="#7499FF"
                ;;
        *"Warning"* )
                color="warning"
                ;;
        *"Average"* )
                color="#FFA059"
                ;;
        *"High"* )
                color="#E97659"
                ;;
        *"Disaster"* )
                color="danger"
                ;;
        * )
                color="#CCCCCC"
                ;;
    esac
fi

# Build our JSON payload and send it as a POST request to the Slack incoming web-hook URL
payload="payload={\"channel\": \"${to//\"/\\\"}\", \"username\": \"${username//\"/\\\"}\", \"attachments\": [ { \"fallback\": \"${message//\"/\\\"}\", \"title\": \"${subject//\"/\\\"}\", \"text\": \"${message//\"/\\\"}\", \"color\": \"${color//\"/\\\"}\", \"mrkdwn_in\": [\"text\"] } ] }"
curl -m 5 --data-urlencode "${payload}" $url -A 'zabbix-slack-alertscript / https://github.com/ericoc/zabbix-slack-alertscript'
