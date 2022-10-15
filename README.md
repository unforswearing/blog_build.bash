About unforswearing.com/blog and blogindexbuild.bash

A flat structure bash-based blog
(as seen at unforswearing.com/blog)

```
blog
  ├── /.data
  ├── /drafts
  ├── index.html
  ├── /posts
  └── /sources
```

Folder Description

.data

- images
- audio files
- other media
    - helper scripts (none yet)
  /drafts
    - posts not ready to be published greated via 'add'
  index.html
    - main blog index page
  /posts
    - published posts generated via 'publish' or 'build'
  /queue
    - posts ready to be published via 'publish'


---

Colophon

- All posts are written in markdown.
- Content is published with a single bash script (inspired by bashblog).
- Typesetting
    - Monospace Font: NotCourierSans
    - Sans Serif Font: Open Sans
- Thanks also to these external tools
    - htmltidy (http://api.html-tidy.org/tidy/quickref_5.2.0.html)
    - commonmark (http://commonmark.org)
    - font awesome (http://fontawesome.io/)
    - highlight.js (https://highlightjs.org/)
    - feedburner (feedburner.com)
