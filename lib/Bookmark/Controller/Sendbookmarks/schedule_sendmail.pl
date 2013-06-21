#!/usr/bin/perl
use strict;
use warnings;
use DateTime;
use DBI;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Transport::SMTP;
use utf8;
use Encode;
use Data::Dumper;
use Schedule::Sendmail;
use POSIX 'strftime';

print ":::::sendbookmark:::::\n";
#ここまでで複数時間を指定してメールを時間に送信できる。

#DBからselect してmemoと時間を指定するだけ。

# データソース
my $d = 'DBI:mysql:bookmarkdb';
# ユーザ名
my $u = 'bookmarkuser';
# パスワード
my $p = '????????????????';

# データベースへ接続
my $db = DBI->connect($d, $u, $p);

if(!$db){
    print "接続失敗\n";
    exit;
}

$db->do("set names utf8");
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
my @weekly = ('Sun', 'Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat'); # 表示したい曜日文字
print "now day:",$weekly[$wday],"\n"; # 曜日を表示
$year += 1900;
$mon += 1;

#時が1桁の場合
if(0 <= $hour && $hour <= 9){
    $hour = "0".$hour;
}
#分が1桁の場合
if(0 <= $min && $min <= 9){
   $min = "0".$min;
}
#秒が1桁の場合
if(0 <= $sec && $sec <= 9){
   $sec = "0".$sec;
}
print "current time:$hour:$min\n";

my $sth_userid = $db->prepare("SELECT userid,email,remind_tag,remind_num,days,hour,minute FROM BookmarkSetting WHERE hour = $hour AND minute = $min AND days LIKE '%$weekly[$wday]%'");#各ユーザーの設定を取得(table:BookmarkSetting)
my $sth_reminded_num = $db->prepare("UPDATE Bookmark SET reminded_num = 0 WHERE reminded_num IS NULL"); #NULLなら0にしておく

if(!$sth_userid->execute || !$sth_reminded_num->execute){
    print "SQL失敗\n";
}
my %doc;
my @docdatas = ();
my $refdocdatas;

#各ユーザーについてのremind_tagのついたデータを取得(table:Bookmark)
while(my @users = $sth_userid->fetchrow_array){
    
    my %usersettingdata = (userid => $users[0],email => $users[1],remind_tag => $users[2] ); #userの設定
    push(@docdatas,\%usersettingdata); #メールの送信に必要な情報を配列の最初に入れておく
    print Dumper @docdatas;
            
    my $tags = $users[2];
    $tags =~ s/\]\[/\],\[/g;
    my @items = split /,/, lc($tags); #tagをすべて小文字にする
    #sort
    my @sortedarray = sort { $a cmp $b } @items;

    my %tmp;
    my @tag = grep(  !$tmp{$_}++, @sortedarray);
    
    foreach my $tag (@tag) {
        my %setting_users = ( userid => $users[0],email => $users[1],remind_tag => $tag, reminded_num => $users[3], days => $users[4], hour => $users[5], minute => $users[6]); #userの設定
        print Dumper %setting_users;
       
        #Bookmarkを取得                         0            1       2                 3             4       5 
        my $Bookmarks = $db->prepare("SELECT me.userid, me.title, me.bookmarkurl,me.originalurl, me.tag ,me.reminded_num FROM Bookmark me WHERE '$setting_users{userid}' = me.userid AND me.tag LIKE '%$setting_users{remind_tag}%' ORDER BY RAND() limit 0, $setting_users{reminded_num}"); #現在時間に一致するBookmarkをランダムに取得(この辺を改善する余地あり)

        if (!$Bookmarks->execute) {
            print "SQL失敗\n";
            #exit;
        }
        my %doc;
        #docの渡し方でuserid,emailなど共通なものをひとつだけ渡す
        while (my @bookmarkrec = $Bookmarks->fetchrow_array) {
            #BookmarkReadから読んだBookmarkを取得
            my $BookmarkReads = $db->prepare("SELECT userid, bookmarkurl, read_num, update_at FROM BookmarkRead WHERE '$setting_users{userid}' = userid");
            if (!$BookmarkReads->execute) {
                print "SQL失敗\n";
                #exit;
            }
            my $sth_bookmarkreadcnt = $db->selectrow_arrayref("SELECT count(*) from BookmarkRead WHERE '$setting_users{userid}' = userid");
            my $bookmarkreadcnt = @$sth_bookmarkreadcnt[0];

            if($bookmarkreadcnt > 0){
                #もし、BookmarkReadにuseridがあり、Bookmarksのbookmarkurlがあれば,read_numを取得.
                my $i = 0;
                my $endwhile = 0;
                while (my @bookmarkreadrec = $BookmarkReads->fetchrow_array) {
                    if($bookmarkrec[2] eq $bookmarkreadrec[1]){ #Bookmark.bookmarkurl eq BookmarkRead.bookmarkurl
                        my %doc = ( title => $bookmarkrec[1],bookmarkurl =>$bookmarkrec[2], originalurl => $bookmarkrec[3], tag => $setting_users{remind_tag}, reminded_num => $bookmarkrec[5]+1,read_num => $bookmarkreadrec[2], update_at => $bookmarkreadrec[3] ); #一つのbookmark
                        push(@docdatas, \%doc); #docdatasにdoc(一つのbookmark)をひとつずつ入れていく
                        $endwhile = 1;
                    }elsif($endwhile != 1 && $i == $bookmarkreadcnt - 1 ){
                        my %doc = ( title => $bookmarkrec[1],bookmarkurl =>$bookmarkrec[2], originalurl => $bookmarkrec[3], tag => $setting_users{remind_tag}, reminded_num => $bookmarkrec[5]+1, read_num => '0'); #一つのbookmark
                        push(@docdatas, \%doc); #docdatasにdoc(一つのbookmark)をひとつずつ入れていく
                        $endwhile = 1;
                    }
                    $i = $i + 1;
                    if($endwhile == 1){
                        last;
                    }
                }
            }else{
                my %doc = ( title => $bookmarkrec[1],bookmarkurl =>$bookmarkrec[2], originalurl => $bookmarkrec[3], tag => $setting_users{remind_tag}, reminded_num => $bookmarkrec[5]+1, read_num => '0'); #一つのbookmark
                push(@docdatas, \%doc); #docdatasにdoc(一つのbookmark)をひとつずつ入れていく
            }
            #DBのreminded_numを1増やす
            my $update_reminded_num = $db->prepare("UPDATE Bookmark SET reminded_num = reminded_num + 1 WHERE bookmarkurl = '$bookmarkrec[2]'"); #NULLなら0にしておく
            # MySQLの日付時刻型( datetime型 )
            # my $current_datetime = strftime( "%Y-%m-%d %H:%M:%S" , localtime );
            my $current_datetime = $year."-".$mon."-".$mday." ".$hour.":".$min.":".$sec;
            my $insert_remindhistory = $db->prepare("INSERT INTO RemindHistory (sendtime, bookmarkurl) VALUES ('$current_datetime','$bookmarkrec[2]')");
            #print Data::Dumper $insert_remindhistory;
            if (!$update_reminded_num->execute || !$insert_remindhistory->execute) {
                print "SQL失敗\n";
                #exit;
            }
            
        }

    
        print "Current all sendmail record:\n";
        print Dumper @docdatas;
        if (!@docdatas) {
            print "docdatas record is empty\n";
        }
    }
    
    my $refdocdatas = \@docdatas;
    &Schedule::Sendmail::sendbookmark($refdocdatas);
}


=pod
Current all sendmail record:
$VAR1 = {
          'email' => 'XXXXXXXX@gmail.com',
          'userid' => 'infinith4',
          'remind_tag' => 'あとで読む'
        };
$VAR2 = {
          'tag' => 'あとで読む,',
          'title' => '何かを好きになることと無意識との関係',
          'originalurl' => 'http://www.yhsk.info/?p=1447',
          'bookmarkurl' => 'http://b.hatena.ne.jp/infinith4/20130329#bookmark-133320442'
        };
$VAR3 = {
          'tag' => 'facebook,あとで読む,',
          'title' => 'フェイスブック、アプリ開発者とのあつれき広がる - WSJ.com',
          'originalurl' => 'http://jp.wsj.com/article/SB10001424127887324823704578369891154640084.html?google_editors_picks=true',
          'bookmarkurl' => 'http://b.hatena.ne.jp/infinith4/20130319#bookmark-137238742'
        };

=cut
