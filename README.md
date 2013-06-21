This repository is OSS.

- Bookmark remind Hatenabookmark by email.
Useage

Run:
1-1.
???????????

1-2.
Modified Hatena Auth key in lib/Bookmark/Controller/Root.pm .

1-3.
Modified /lib/Bookmark/Controller/Sendbookmarks/Schedule/Sendmail.pm

localhost => reminder.asia

2.
On screen,
script/bookmark_server.pl -r -p 4000

3.
On screen,
$ cd lib/Bookmark/Controller/Sendbookmarks
$ perl Sendbookmarks.pl

4.
On screen,
$ cd lib/Bookmark/Controller/Modified_bookmark
$ perl Auto_modified_bookmark.pl

5.
On screen,
perl lib/Bookmark/Controller/Auto_update_new_tag.pl 
This program is Get and Update Tag from atomfeed,Into BookmarkUserTag,BookmarkTag table in bookmarkdb. 

