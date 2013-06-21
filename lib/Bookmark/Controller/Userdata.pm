package Userdata;

use strict;
use warnings;
use XML::FeedPP;
use XML::Simple;
use Data::Dumper;
use Array::Uniq;

#http://b.hatena.ne.jp/'.$userid.'/atomfeed?tag='.$tag.'&of=0'; 特定のタグの数を取得
sub allnum {
    my @arry = @_;
    my $arrynum = @arry;
    my $userid = $arry[0];
    my $source;
    my $num;
    if ($arrynum == 2){
        my $tag = $arry[1];
        $source = 'http://b.hatena.ne.jp/'.$userid.'/atomfeed?tag='.$tag.'&of=0';
        print $source,"\n";
        my $feed = XML::FeedPP->new( $source );
        if($feed->title() =~ /\s\([0-9]+\)$/){
            my $str = "$&";
            if($str =~ /[0-9]+/){
                $num = $&;
            }
        }

    }else{
        $source = "http://b.hatena.ne.jp/".$userid."/rss";
        my $feed = XML::FeedPP->new( $source );
        
        $num = $feed->get('opensearch:totalResults');

    }
    return $num;
}

#最新のブックマークについたタグを取得
sub getmaintag {
    my (@user) = @_;
    my @tags = ("");
    my $allnum = allnum(@user);
    #print Dumper $allnum;
    my $userid = $user[0];
    for (my $i=0;$i < $allnum;$i = $i+20){
        #print $i,"\n";
        #tagを取得
        my $source = 'http://b.hatena.ne.jp/'.$userid.'/atomfeed?of='.$i;
        
        my $feed = XML::FeedPP->new( $source );
        foreach my $item ( $feed->get_item() ) {
            my @feedtags = $item->get("dc:subject");
            
            foreach my $tag (@feedtags){
                if(defined($tag)){
                    @tags = uniq sort {"\L$a" cmp "\L$b"} @tags; #重複削除
                    my $tagsnum = @tags;
                    my $cut = 0;
                    for (my $i = 0;$i<$tagsnum;$i++){
                        if(lc($tags[$i]) eq lc($tag)){
                            $i = $tagsnum;
                            $cut = 1;
                        }
                        
                    }
                        if (lc($tag) ne lc($tags[$#tags]) && $cut !=1){
                            push(@tags,$tag);
                        }
                }
                if($#tags >= 10){
                    $i = $allnum;
                }
            }
            
        }
    }
    return @tags;
}

#ブックマークのタグをすべて取得
sub getalltag {
    my (@user) = @_;
    my @tags = ("");
    my $allnum = allnum(@user);
    #print Dumper $allnum;
    my $userid = $user[0];
    for (my $i=0;$i < $allnum;$i = $i+20){
        sleep 5; #連続してアクセスするとXML::FeedPP->new( $source )を取得する際に,止まるので一時停止する.

        #tagを取得
        my $source = 'http://b.hatena.ne.jp/'.$userid.'/atomfeed?of='.$i;
        print $source,"\n";
        my $feed = XML::FeedPP->new( $source );
        foreach my $item ( $feed->get_item() ) {
            my @feedtags = $item->get("dc:subject");
            
            foreach my $tag (@feedtags){
                if(defined($tag)){
                    @tags = uniq sort {"\L$a" cmp "\L$b"} @tags; #重複削除
                    my $tagsnum = @tags;
                    my $cut = 0;
                    for (my $i = 0;$i<$tagsnum;$i++){
                        if(lc($tags[$i]) eq lc($tag)){
                            $i = $tagsnum;
                            $cut = 1;
                        }
                        
                    }
                        if (lc($tag) ne lc($tags[$#tags]) && $cut !=1){
                            push(@tags,$tag);
                        }
                    
                }
            }
            
        }
    }
    return @tags;
}

1;

=pod
my $userid = "infinity_th4";
my $tag = "あとで読む";

my @arry = ($userid,$tag);
print "All:",allnum(@arry),"\n";

my @arry1 = ($userid);
print "All:",allnum(@arry1),"\n";

=cut
