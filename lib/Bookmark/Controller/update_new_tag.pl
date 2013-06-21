#!/usr/bin/perl

use strict;
use warnings;
use Userdata;
use DBI;
use URI::Escape;
use Data::Dumper;
use POSIX 'strftime';

# データソース
my $d = 'DBI:mysql:bookmarkdb';
# ユーザ名
my $u = 'bookmarkuser';
# パスワード
my $p = '????????????????????????';

# データベースへ接続
my $db = DBI->connect($d, $u, $p);

if(!$db){
    print "接続失敗\n";
    exit;
}
$db->do("set names utf8");

my $sth = $db->prepare("SELECT userid FROM BookmarkUser"); #ユーザの各タグについて,昇順でtagid,tagを取得.
if(!$sth->execute){
    print "SQL失敗\n";
    #exit;
}else{
    #print "ok\n";
}

my @users;
while(my @rec = $sth->fetchrow_array){ #BookmarkUserの各カラムの要素を取得 $rec[0]:userid.
    my $bookmarkuser_userid = $rec[0];
    push(@users,$bookmarkuser_userid);
}

print @users,"\n";


#毎回タグを取ってきたら時間がかかりすぎる
#すべてのタグを取得

foreach(@users){
    print "useid:$_\n";
    &inserttag($_);
}

sub inserttag {
    my $userid = shift;

    my @user = ($userid);
    my @tags = Userdata::getalltag(@user);

    foreach (@tags){
        my $created = strftime( "%Y-%m-%d %H:%M:%S" , localtime );
        my $tag = lc($_); #タグを小文字にする
        my $prime = uri_escape("\'"); #primeをuri_escapeする.戻すときは,$tagごと,uri_unescapeすれば良い.
        $tag =~ s/\'/$prime/;

        my $sth = $db->prepare("SELECT tagid,tag FROM BookmarkTag order by tag asc"); #ユーザの各タグについて,昇順でtagid,tagを取得.
        if(!$sth->execute){
            print "SQL失敗\n";
            #exit;
        }else{
            print "SQL成功\n";
        }
        #my $double_quotation = uri_escape("\"");

        my $insertnum = 1;#1なら登録する,0なら登録しない
        while(my @rec = $sth->fetchrow_array){ #BookmarkTagの各カラムの要素を取得 $rec[0]:tagid,$rec[1]:tag.
            #print $rec[0],":",$rec[1],"\n";
            my $bookmarktag_tag= $rec[1];
            if( $bookmarktag_tag eq $tag ){ #登録しようとするtagとBookmarkTagにあるtagが一致していなければ,登録する.
                $insertnum = 0;
                my $sth_select_tagid = $db->prepare("SELECT tagid FROM BookmarkTag WHERE tag='$tag'"); #ユーザの各タグについて,昇順でtagid,tagを取得.
                if(!$sth_select_tagid->execute){
                    print "SQL失敗\n";
                    #exit;
                }else{
                    print "SQL成功\n";
                }
                my $tagid;
                while (my @rectagid = $sth_select_tagid->fetchrow_array){ #BookmarkTag の最後のtagid を取得
                    $tagid = $rectagid[0]; #BookmarkUserTagに追加するtagid.
                }
                my $sth_bookmarkusertag = $db->prepare("INSERT INTO BookmarkUserTag (userid,tagid,created) VALUES ('$userid','$tagid','$created')");
                if(!$sth_bookmarkusertag->execute){
                    print "BookmarkUserTag SQL失敗\n";
                    #exit;
                }else{
                    print "Insert BookmarkUserTag\n";
                }

            }
        }
        print "insertnum:$insertnum\n";
        if ($insertnum == 1) {
            print "insert tag:",$tag,"\n";
            my $sth_bookmarktag = $db->prepare("INSERT INTO BookmarkTag (tag) VALUES ('$tag')");#tagid,tagはunique.tagidは,autoincrement.
            if(!$sth_bookmarktag->execute){
                print "BookmarkTag SQL失敗\n";
                exit;
            }else{
                print "Insert BookmarkTag\n";
            }
            my $sth_select_tagid = $db->prepare("SELECT tagid FROM BookmarkTag order by tagid desc LIMIT 1"); #ユーザの各タグについて,昇順でtagid,tagを取得.
            if(!$sth_select_tagid->execute){
                print "SQL失敗\n";
                #exit;
            }else{
                print "ok\n";
            }
            my $tagid;
            while (my @rectagid = $sth_select_tagid->fetchrow_array){ #BookmarkTag の最後のtagid を取得
                $tagid = $rectagid[0]; #BookmarkUserTagに追加するtagid.
            }
            my $sth_bookmarkusertag = $db->prepare("INSERT INTO BookmarkUserTag (userid,tagid,created) VALUES ('$userid','$tagid','$created')");
            if(!$sth_bookmarkusertag->execute){
                print "BookmarkUserTag SQL失敗\n";
                #exit;
            }else{
                print "Insert BookmarkUserTag\n";
                
            }
            
        }
    }
}


