#!/bin/bash

pc=$(cat ~/monitoring/alarm/catalogue | awk '{print$2}' | sed -n 1p | cut -d '=' -f2)
oc=$(cat ~/monitoring/alarm/cartalouge | awk '{print$2}' | sed -n 2p | cut -d '=' -f2)

POD=$(kubectl get deployments.apps -n sock-shop catalogue | awk '{print $2}' | sed -n 2p | cut -d '/' -f1)

if [ -z ${pc} ]; then
	        echo "export POD=${POD}" >> ~/monitoring/alarm/catalogue
else
	sed -i "s/${pc}/${POD}/g" ~/monitoring/alarm/catalogue
fi

if [ -z ${oc} ]; then
	echo "export OLD=${POD}" >> ~/monitoring/alarm/catalogue
	exit 0
else
	sed -i "s/${oc}/${POD}/g" ~/monitoring/alarm/catalogue
fi


if [ ${oc} -lt ${POD} ]; then
	curl -X POST --data-urlencode "payload={\"channel\": \"#일반\", \"username\": \"jongbot\", \"text\": \"catalogue가 ${POD}개로 scale out 되었습니다.\", \"icoemoji\": \":ghost:\"}" https://hooks.slack.com/services/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
elif [ ${oc} -gt ${POD} ]; then
	curl -X POST --data-urlencode "payload={\"channel\": \"#일반\", \"username\": \"jongbot\", \"text\": \"catalogue가 ${POD}개로 scale in 되었습니다.\", \"icoemoji\": \":ghost:\"}" https://hooks.slack.com/services/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
else
	echo "no scaling"
fi
