#!/bin/sh

cat << EOF > /usr/share/nginx/html/scripts/local.js
const localWordsAPI = "${LOCAL_WORDS_API}"
const localPlayerAPI = "${LOCAL_PLAYER_API}"
const localGameAPI = "${LOCAL_GAME_API}"
const localMetricsAPI = "${LOCAL_METRICS_API}"
EOF

# Start Nginx
exec nginx -g 'daemon off;'
