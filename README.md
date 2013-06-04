# Bookmarking

A bookmaking facility to Vim for marking points of interest.

Adds a book marking feature to Vim that allows lines of interest to be
marked. While similar to marks, you don't need to assign a bookmark to
a mark key, instead an infinite number of bookmarks can be created and
then jumped through in sequential order (by line number) with no
strain on your memory. This is great to use when you are browsing
through some source code for the first time and need to mark out
places of interest to learn how it works.

## Using

The bookmark facility provides a number of new commands as well as a
default mapping of these commands to keys. This mapping can be
customised as can the bookmarks appearance.

Bookmarks can be created using the `ToggleBookmark` command. This will
place a bookmark at the current location in the file, which should be
visually visible. You can then jump around the bookmarks in a file by
using the `NextBookmark` and `PreviousBookmark` commands.

## Get involved!

We are happy to receive bug reports, fixes, documentation
enhancements, and other improvements.

Please report bugs via the
[github issue tracker](http://github.com/dterei/VimBookmarking/issues).

Master [git repository](http://github.com/dterei/VimBookmarking):

* `git clone git://github.com/dterei/VimBookmarking.git`

## Licensing

This library is BSD-licensed.

## Authors

This library is written and maintained by David Terei,
<code@davidterei.com>.

