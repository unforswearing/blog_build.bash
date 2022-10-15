#!/usr/bin/env bash

rssfeed="$HOME"/Documents/Shared/Scripts/Projects/unforswearing.com/html/blog/rss.xml

_rsshead_() {
    echo "<?xml version=\"1.0\"?>
<rss version=\"2.0\">
  <channel>
    <title>unforswearing.com/blog</title>
    <link>http://unforswearing.com/blog</link>
    <description>Applescript, Bash, and other minor conveniences</description>
    <language>en-us</language>
    <pubDate>$(date -R)</pubDate>"
}

_rssclose_() {
echo "</channel>
</rss>"
}

_itemrss_(){
    local date
    date=$(date -d "$indexDateFormatting" +'%m/%d/%Y')

    echo "<item>
     <title>$title</title>
     <link>$htmlURL</link>
     <description>$title</description>
     <pubDate>$date</pubDate>
     <guid>$(uuidgen)</guid>
   </item>"
}

_rsshead_ > $rssfeed
