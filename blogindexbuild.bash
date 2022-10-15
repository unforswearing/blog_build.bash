#!/usr/local/bin/bash
# ALL POSTS ARE MADE LOCALLY (on macbook pro)

# TO DO
#

# BEGIN # -------------------------------------------------------

# Because emacs is super slow...
EDITOR="nano"

# Set up some smooth-n-easy variables
blogroot=""$HOME"/Documents/Shared/Scripts/Projects/unforswearing.com/html/blog"
data="$blogroot/.data"
index="$blogroot/index.html"
posts="$blogroot/posts/"
sources="$blogroot/sources/"

_help() {
    echo "
blogindexbuild.bash

options:
    build           buld the blog from scratch with a folder full of markdown files
    new             add a new post to the blog you built
    rebuild         reindex the markdown source files and build an updated index page
"

}

# GENERATE RSS #---------------------------------------------------
rssfeed="$HOME"/Documents/Shared/Scripts/Projects/unforswearing.com/html/blog/rss.xml

_rsshead_() {
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<rss version=\"2.0\">
    <channel>
        <title>unforswearing.com/blog</title>
        <link>https://unforswearing.com/blog</link>
        <description>Applescript, Bash, and other minor conveniences</description>
        <language>en-us</language>
        <pubDate>$(date -R)</pubDate>"

}

_rssclose_() {
echo "  </channel>
</rss>"

}

_itemrss_(){
    local date
    date=$(date -d "$indexDateFormatting 16:00" --rfc-2822)

    echo "      <item>
            <title>$title</title>
            <link>$htmlURL</link>
            <description>$description</description>
            <pubDate>$date</pubDate>
            <author>hello@unforswearing.com</author>
        </item>" >> $rssfeed

}

# [BUILD] CREATE OR REFRESH INDEX.HTML #--------------------------------------------------
_style() {
    echo "<html>
<head>
    <title>unforswearing.com/blog</title>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"/css/u.css\">
    <link rel=\"stylesheet\" type=\"text/css\" href=\"/css/b.css\">
    <link rel=\"stylesheet\" type=\"text/css\" href=\"/css/font-awesome/css/font-awesome.min.css\">

    <link rel=\"stylesheet\" href=\"//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.7.0/styles/default.min.css\">
    <script src=\"//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.7.0/highlight.min.js\"></script>

    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
</head>
<body class=\"sans pad\">
<div class=\"indexlink topwidth header\">
    <h1>
        <a class=\"home\" href=\"/\">UNFORSWEARING.COM</a>/<a class=\"home\" href=\"/blog\">BLOG</a>
        </h1>
    </div>
    <div class=\"narrow\">
<br /><br />"

}

_closetags() {
    echo "</div>
</body>
<script>hljs.initHighlightingOnLoad();</script>
</html>"

}

_htmlToMarkdown() {
    # convert md to html
    mdURL="https://unforswearing.com/blog/sources/"$(basename $post)""
    local postbeingprocessed="${post/.md/.html}"
    sleep .1

    # CSS
    _style > "$postbeingprocessed"

    # post content
    /usr/local/bin/cmark --hardbreaks $post >> "$postbeingprocessed"

    # footer navigation
    _postFooter() {
        echo "<div class=\"footer\">
<hr class=\"light\">
<a href=\"/blog\">back</a>&nbsp;&nbsp;
<a href=\"$mdURL\">view markdown</a>
<span style=\"float: right;\">
<a href=\"/github\"><i class=\"fa fa-github fa-lg my-fa-github\"></i></a>&nbsp;&nbsp;
<a href=\"http://feeds.feedburner.com/unforswearing\"><i class=\"fa fa-rss fa-lg my-fa-rss\"></i></a>
</span>
</div>"

    }

    _postFooter >> "$postbeingprocessed"

    # close html tags to avoid errors
    _closetags >> "$postbeingprocessed"

}

_generateIndex() {
    # url as on blog: 20161003: this is a post for blog [md]
    _camelCase_() {
        tr "[:upper:]" "[:lower:]" | perl -ane ' foreach $wrd ( @F ) { print ucfirst($wrd)." "; } print "\n" ; '

    }

    description=$(/usr/local/bin/pandoc -t plain $post | \
        grep -v '^$' | \
        tail -n +2 | \
        tr '\n' ' ' | \
        awk -F'[\.\?\!\:]' '{ print $1 }' 2>/dev/null \
        )

    local post=$(basename $post)

    # Check for urls as or in post names
    #     if [[ $post =~ ^https? ]]; then
    #         title=$post
    #     else
    title=$(echo $post | sed 's/[0-9]*-//; s/\.md//; s/-/ /g' | _camelCase_)
    # fi

    date=$(echo $post | awk -F- '{print $1}')

    # mdURL="https://unforswearing.com/blog/sources/"$post""
    htmlURL="https://unforswearing.com/blog/posts/"${post/.md/.html}""
    indexDateFormatting=$(echo $date | sed -e "s/.\{4\}/&\-/; s/.\{7\}/&\-/;")

    local indexDate="<span class=\"date\">$indexDateFormatting:</span>"
    local indexTitle="<a class=\"sans index\" href=\"$htmlURL\">$title</a>"

    echo "<p>$indexDate $indexTitle</p>" >> "$blogroot/index.html"

}

_buildPrep() {
    find $posts -iname "*.html" -delete

    local sourcefile
    while read sourcefile; do
        mv $sourcefile $posts
    done < <(find $sources -iname "*.md")
}

_buildCleanup() {
    local sourcefile
    while read sourcefile; do
        mv $sourcefile $sources
    done < <(find $posts -iname "*.md")

    # use 'tidy'
    while read untidy; do
        /usr/local/bin/tidy -indent -modify --drop-empty-elements no --wrap 80 --tidy-mark no --doctype strict -file $data/tidy.log "$untidy"
    done < <(find $posts -iname "*.html")

    /usr/local/bin/tidy -indent -modify --drop-empty-elements no --wrap 80 --tidy-mark no --doctype strict -file $data/tidy.log "$index"

}

_build() {
    _indexFooter() {
        local updated=$(date --rfc-2822)
        echo "<div class=\"footer\">
<hr class=\"light\">
<a href=\"/github\"><i class=\"fa fa-github fa-lg my-fa-github\"></i></a>&nbsp;&nbsp;
<a href=\"http://feeds.feedburner.com/unforswearing\"><i class=\"fa fa-rss fa-lg my-fa-rss\"></i></a>
<span style=\"font-size: 15px;color:#858585;float:right;\"><em>updated: $updated</em></span>
</div>"
    }

    echo "Preparing to build"
    _buildPrep

    echo "Building 'index.html'"
    _style > $index
    _rsshead_ > $rssfeed

    while read post; do
        _htmlToMarkdown
        _generateIndex
        _itemrss_
    done < <(find $posts -iname "*.md" | sort -d | sort -r)

    _indexFooter >> $index
    _closetags >> $index
    _rssclose_ >> $rssfeed

    echo "Done."
    _buildCleanup

}

# [ADD] CREATE AND PUBLISH A NEW BLOG POST #------------------------------------------------------------------------

_createNewPostFromTemplate() {
    read -p "Please enter a title: " newposttitle

    newposttitle_filename=$(echo $newposttitle | sed 's/ /-/g; s/-$//g')
    newpost="$posts$(date +'%Y%m%d')-$newposttitle_filename.md"

    until [ -f $newpost ]; do $EDITOR $newpost; done && _build
}

case "$1" in
    build|rebuild) _build ;;
    new) _createNewPostFromTemplate ;;
    ""|help) _help ;;
esac
