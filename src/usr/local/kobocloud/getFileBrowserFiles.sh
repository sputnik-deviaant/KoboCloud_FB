#!/bin/sh

baseURL="$1"
outDir="$2"

# load config
. $(dirname $0)/config.sh

token=`echo "$baseURL" | sed -n 's@.*/\([^/?]*\).*@\1@p'`

# get directory listing via FileBrowser public API
listJSON=`$CURL -k -L --silent "$baseURL/api/public/share/$token"`

echo "$listJSON" |
  grep -Eo '"path":"[^"]+"' |
  sed 's/"path":"\([^"]*\)"/\1/' |
  while read filePath
  do
    if echo "$filePath" | grep -q '/$'; then
      # skip directories
      continue
    fi
    fileName=`basename "$filePath"`
    linkLine="$baseURL/api/public/dl/$token/$filePath"
    localFile="$outDir/$fileName"

    $KC_HOME/getRemoteFile.sh "$linkLine" "$localFile"
    if [ $? -ne 0 ] ; then
        echo "Having problems contacting FileBrowser. Try again in a couple of minutes."
        exit
    fi
  done
