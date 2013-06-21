#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my %doc;

my @docdatas = ();

my %doc = (doc1 => 'a1',doc2 => 'a2',doc3 => 'a3');

push(@docdatas,\%doc);


%doc = (doc1 => 'b1',doc2 => 'b2',doc3 => 'b3');

push(@docdatas,\%doc);

print Dumper @docdatas;

$docdatas[1]{'doc1'} = 'aa1';

print Dumper @docdatas;

use DBI;

# データソース
my $d = 'DBI:mysql:bookmarkdb';
# ユーザ名
my $u = 'bookmarkuser';
# パスワード
my $p = '???????????????????';

# データベースへ接続
my $db = DBI->connect($d, $u, $p);

if(!$db){
    print "接続失敗\n";
    exit;
}

$db->do("set names utf8");

my $sth = $db->prepare('SELECT COUNT(*) FROM BookmarkRead');
$sth->execute;


if($sth->fetchrow_array){
while(my @rec = $sth->fetchrow_array){
    print Dumper @rec;
    my $cnt = @rec[0];
    print $cnt,"\n";
	print join(',', @rec)."\n";
}
}

my $count = $db->selectrow_arrayref("SELECT count(*) from BookmarkRead");
print @$count[0];
