#!/bin/sh

#### KAZOO - FREESWITCH OFFLINE
##
##  run this command in a whapps server on a kazoo cluster to obtain the synchronization key
##
##  sup whapps_config get crossbar.freeswitch offline_configuration_key `sup wh_util rand_hex_binary 32 | sed  s/[\<\"\>]*//g`  | sed  s/[\<\"\>]*//g
##
##  to change the key use the following command
##
##  sup whapps_config set crossbar.freeswitch offline_configuration_key `sup wh_util rand_hex_binary 32 | sed  s/[\<\"\>]*//g`  
##
##  
##
####

KEY=86d4f72ba888dba211fa2d17dcb558f0c8483e1ca5a048757b7d0e9204a3c24e

curl --insecure https://your-kazoo-api-fqdn:8443/v2/freeswitch?key=${KEY} -o update.zip
sudo unzip -o -d /etc/kazoo/freeswitch update.zip
fs_cli --execute reloadxml
