#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use utf8;
use Data::Dumper;
use DateTime;
use XML::FeedPP;
use HTML::TreeBuilder;
use URI::Escape;
use URI;

# データソース
my $d = 'DBI:mysql:bookmarkdb';
# ユーザ名
my $u = 'bookmarkuser';
# パスワード
my $p = '???????????????????????';

# データベースへ接続
my $db = DBI->connect($d, $u, $p);

if(!$db){
    print "接続失敗\n";
    exit;
}
$db->do("set names utf8");

#http://b.hatena.ne.jp/".$userid."/rss",すべでのブックマークの数を取得
sub allbookmarknum {
    my ($userid) = @_;
    my $rssurl = "http://b.hatena.ne.jp/".$userid."/rss";
    my $feed = XML::FeedPP->new( $rssurl );

    return $feed->get("opensearch:totalResults");
}

#ユーザのすべてのブックマークを取得し,Bookmark tableに登録
sub modefiedbookmark {
    my ($userid,$settingtime) = @_;
    print ":::::Modefied, Bookmark of $userid :::::\n";
    my $dt = DateTime->now(time_zone => 'local');
    print "currenttime:",$dt->strftime("%F %T"),"day:",$dt->strftime("%a"),"\n";
    #ここからDBに登録
    my $offset = 0;
    my $maxnum = allbookmarknum($userid);
    print "maxnum:",$maxnum,"\n";
    my $i = 0;
    while($i<int($maxnum / 20 ) + 1){
        $offset = 20*$i;
        print "offset:",$offset,"\n";
        my $source = 'http://b.hatena.ne.jp/'.$userid.'/atomfeed?of='.$offset;
        my $feed = XML::FeedPP->new( $source );
        sleep(10);
        #タグが定義されていない場合.
        #remind_tag が''ならすべてのブックマークからdc:subjectが定義されていないitemをinsert
        #$remind_tag eq '' なら!defined($item->get('dc:subject'))
        foreach my $item ( $feed->get_item() ) {
            my $tree = HTML::TreeBuilder->new;
            my $bookmarkurl = $item->link(); #bookmarkのurl(bookmarkurl)    
            my $title = $item->title();      #title
            print $title,"\n";
            my $description = $item->description(); #description
            $tree->parse($description);
            $tree->eof();
            my @a = $tree->find("a");
            my $originalurl = $a[0]->attr('href'); #Bookmarkの直リンク(originalurl)
                
            my $perm = "<a target='_blank'";
            $description =~ s/<\s*?a/$perm/g; #新しいタブで開くようにaタグを置換
            my @tags = $item->get("dc:subject") || ();
            my $tag = "";
            if(@tags){
                foreach (@tags) {
                    $tag = $tag."[$_]";
                }
            }else{
                $tag = "[]";
            }
            
            #if(@tags){
            #    $tag = join("," , @tags); #tag(カンマ区切り)
            #}
            
            my @test = ($bookmarkurl,$title,$originalurl,$tag,$description);
            #bookmarkurl が一致していたら,UPDATEし,存在しなかったら,INSERTする.
=pod
            my $uri_userid = uri_escape($userid);
            my $uri_bookmarkurl = uri_escape($bookmarkurl);
            my $uri_title = uri_escape($title);
            my $uri_originalurl = uri_escape($originalurl);
            my $uri_tag = uri_escape($tag);
            my $uri_description = uri_escape($description);
=cut            
            my $uri_escape_prime = uri_escape("\'"); #primeをuri_escapeする.戻すときは,$tagごと,uri_unescapeすれば良い.
            
            #my $uri_escape_double_quotation = uri_escape("\"");
            $originalurl  =~ s/\'/$uri_escape_prime/g;
            $title  =~ s/\'/$uri_escape_prime/g;
            $tag  =~ s/\'/$uri_escape_prime/g;
            $description  =~ s/\'/$uri_escape_prime/g;
            
=pod
            print $userid,"\n";
            print $uri_userid,"\n";
            print $bookmarkurl,"\n";
            print $uri_bookmarkurl,"\n";
            print $title,"\n";
            print $uri_title,"\n";
            print $originalurl,"\n";
            print $uri_originalurl,"\n";
            print $tag,"\n";
            print $uri_tag,"\n";
=cut
            #print "des:",$description,"\n";
            #my $un_description = uri_unescape($description);
            #print "un_des:",$un_description,"\n";
            
#            print $uri_description,"\n";

#=pod
            my $sth_update_or_insert = $db->prepare("INSERT INTO `Bookmark` (bookmarkurl, userid, originalurl, title, tag, description ) VALUES ('$bookmarkurl','$userid','$originalurl','$title','$tag', '$description') ON DUPLICATE KEY UPDATE userid=VALUES(`userid`), originalurl=VALUES(`originalurl`), title=VALUES(`title`), tag=VALUES(`tag`), description=VALUES(`description`) ");
            if(!$sth_update_or_insert->execute){
                print "SQL失敗\n";
                #exit;
            }else{
                print "Insert $title\n";
            }
# =pod
#             my $sth_insert_bookmarkread = $db->prepare("INSERT INTO `BookmarkRead` (bookmarkurl) VALUES ('$bookmarkurl') ");
#             if(!$sth_insert_bookmarkread->execute){
#                 print "SQL失敗\n";
#             }

# =cut

            $tag = "";
                
        }
        $i++;
    }

}


sub allbookmarkuser {
    my $sth_userid = $db->prepare("SELECT userid FROM BookmarkUser");#各ユーザーの設定を取得(table:BookmarkSetting)
    if(!$sth_userid->execute){
        print "SQL失敗\n";
        #exit;
    }
    my @userids;
    while(my @users = $sth_userid->fetchrow_array){
        push( @userids, $users[0]);
    }
    return @userids;
}

my @userids = allbookmarkuser();

my $settingtime = "0000-00-00 00:00:00";
foreach (@userids){
    modefiedbookmark($_,$settingtime);
}


