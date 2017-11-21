#!/usr/bin/env bash

LINUX_SPOTIFY_CONF="$HOME/.var/app/com.spotify.Client/config/spotify/prefs"
MACOS_SPOTIFY_CONF="$HOME/Library/Application\ Support/Spotify/prefs"

if [ -e $LINUX_SPOTIFY_CONF ]; then
	SPOTIFY_CONF=$LINUX_SPOTIFY_CONF
elif [ -e $MACOS_SPOTIFY_CONF ]; then
	SPOTIFY_CONF=$MACOS_SPOTIFY_CONF
else
	echo "spotify prefs not found"
	exit 1
fi

PROXY_TYPE=http
PROXY=$(curl "http://pubproxy.com/api/proxy?limit=1&format=txt&type=${PROXY_TYPE}&country=US&http=true")
ret_code=$?
if [ $ret_code != 0 ]; then
      echo "Error when executing command: 'curl'"
      exit $ret_code
elif [[ $PROXY =~ ([0-9]{1,3}\.){3}([0-9]{1,3}):[0-9]{1,4} ]]; then
	if grep -q 'network.proxy.addr="' $SPOTIFY_CONF; then 
		echo "updating proxy to $PROXY"
		sed -i.bck -E 's/(network.proxy.addr=")[^"]+"/\1'$PROXY'@'$PROXY_TYPE'"/' $SPOTIFY_CONF
	else
		echo "adding proxy settings $PROXY"
		if grep -q 'network.proxy.mode=' $SPOTIFY_CONF; then
			sed -i.bck -E 's/(network.proxy.mode=)[0-9]+/\12/' $SPOTIFY_CONF
		else
			echo -e "network.proxy.mode=2\n" >> $SPOTIFY_CONF
		fi
		echo -e 'network.proxy.addr="'$PROXY'@'$PROXY_TYPE'"\n' >> $SPOTIFY_CONF
	fi
else
	echo "bad proxy reply $PROXY"
fi
