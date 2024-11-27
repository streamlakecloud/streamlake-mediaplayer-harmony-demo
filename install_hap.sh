#!/bin/bash
set -e
NOW_DIR=$(
  cd "$(dirname $0)"
  pwd
)
cd $NOW_DIR

appid=com.sl.ksplayer.openharmonydemo

hdc shell aa force-stop ${appid}

if [[ $1 == 'cls' || $1 == 'clean' ]];then
  echo "clean app"
  hvigorw clean
fi

 hvigorw assembleHap --mode module -p module=entry_sl@default -p product=default --no-daemon

hdc install entry_sl/build/default/outputs/default/entry_sl-default-signed.hap
hdc shell aa start -a EntryAbility -b ${appid}
