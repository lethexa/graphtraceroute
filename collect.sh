#!/bin/sh

HOSTNAME="$1"
TRACEROUTE="traceroute"
SQLITE="sqlite3"
DBNAME="routermesh.db"

$SQLITE -line $DBNAME "CREATE TABLE routers(thishop TEXT, nexthop TEXT);"

PREVADDR='0.0.0.0';
$TRACEROUTE $HOSTNAME | grep '^\s*[0-9]\+ ' | awk '{ if(NR > 1) print $3; }' | sed 's/[(,)]//g' | sed 's/[\*]/--/g' | while read ADDR; do
  echo "$PREVADDR -> $ADDR";
  EXISTS=`$SQLITE $DBNAME "SELECT COUNT(*) FROM routers WHERE thishop='$PREVADDR' AND nexthop='$ADDR'"`

  echo "$EXISTS"

  if [ "$EXISTS" = "0" ] 
  then
    $SQLITE -line $DBNAME "INSERT OR IGNORE INTO routers (thishop,nexthop) VALUES ('$PREVADDR','$ADDR');"
  fi
  PREVADDR=$ADDR
done
