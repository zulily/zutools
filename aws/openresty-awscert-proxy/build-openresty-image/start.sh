#!/bin/bash

# Configure Auth
if [ -n "${ENABLE_SSL+1}" ] && [ "${ENABLE_SSL,,}" = "true" ]; then
  echo "Enabling SSL..."
  cp /usr/src/openresty_ssl.conf /usr/local/openresty/nginx/conf/conf.d/proxy.conf
  # If an htpasswd file is provided, configure nginx 
  if [ -n "${ENABLE_BASIC_AUTH+1}" ] && [ "${ENABLE_BASIC_AUTH,,}" = "true" ]; then
    echo "Enabling basic auth..."
    sed -i "s/#auth_basic/auth_basic/g;" /usr/local/openresty/nginx/conf/conf.d/proxy.conf
  fi
else
  # No SSL
  cp /usr/src/openresty_nossl.conf /usr/local/openresty/nginx/conf/conf.d/proxy.conf
fi


# If rate limiting is requested, set it up, defaulting to 1req/sec.
if [ -n "${ENABLE_HTTP_RATE_LIMIT}" ] && [ "${ENABLE_HTTP_RATE_LIMIT}" = "true" ]; then
  echo "Enabling http rate limiting..."
  sed -i "s/#limit_req_zone/limit_req_zone/g;" /usr/local/openresty/nginx/conf/conf.d/proxy.conf
  sed -i "s/#limit_req /limit_req /g;" /usr/local/openresty/nginx/conf/conf.d/proxy.conf
  if [ -n "${RATE_REQS_SEC}" ]; then
    sed -i "s/{{RATE_REQS_SEC}}/${RATE_REQS_SEC}/g;" /usr/local/openresty/nginx/conf/conf.d/proxy.conf
  else
    sed -i "s/{{RATE_REQS_SEC}}/1/g;" /usr/local/openresty/nginx/conf/conf.d/proxy.conf
  fi  
fi

# Tell nginx the address and port of the service to proxy to
sed -i "s|{{TARGET_SERVICE}}|${TARGET_SERVICE}|g;" /usr/local/openresty/nginx/conf/conf.d/proxy.conf

echo "Starting openresty..."
/usr/local/openresty/bin/openresty -g 'daemon off;'
