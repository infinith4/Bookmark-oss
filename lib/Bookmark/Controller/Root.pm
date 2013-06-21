package Bookmark::Controller::Root;
use Moose;
use namespace::autoclean;
use Digest::MD5 qw/md5_hex/;
use XML::FeedPP;
use Data::Dumper;
use JSON qw/encode_json decode_json/;
use utf8;
use Encode qw/encode_utf8 decode_utf8 encode/;
use LWP::UserAgent;
use Data::Dumper;
use Hatena::API::Auth;
use NEXT;
use HTML::TagParser;
use POSIX 'strftime';
use HTML::TreeBuilder;
use URI::Escape;
use Apikey;

#use lib::Bookmark::Controller::Userdata; #where ?

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Bookmark::Controller::Root - Root Controller for Bookmark

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path("/index") {
    my ( $self, $c ) = @_;

    # Hello World
#    $c->response->body("Bookmark");
}

sub json00 :Local {
    my ( $self, $c ) = @_;

    #スタッシュを用意する
    #$c->stash->{name} = decode_utf8('山田'); #decode('utf8','山田') is error "Cannot decode string with wide characters".
    #$c->stash->{old} = 53;
    #JSON データを出力
    #$c->forward('Bookmark::View::JSON'); #上で準備したstashを,forwardメソッドでBookmark::View::JSON を呼ぶ.
}

sub dbjson :Local {
    my ($self, $c) = @_;
    $c->stash->{list} = [
        map {
            $_ = { map { $_ = decode_utf8($_) } $_->get_columns }
        }
    $c->model('BookmarkDB::BookmarkUserTag')
            ->search({},{
                prefetch => ['usertag_tag'],
                #rows => 6,
                order_by => {-asc => ['me.tagid']}
            })
    ];
    $c->forward('Bookmark::View::JSON');
}

sub anytables_prefetch :Local {
  my ($self, $c) = @_;
  $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUser')
    ->search({ 'me.userid' => 'infinity_th4' }, {
      prefetch => { 'user_usertag' => 'tag' },
      order_by => { -asc => ['user_usertag.tagid']}
    })];
  #$c->stash->{test} = 'test';
  #print Data::Dumper $c->stash->{list};
}

sub prefetch :Local{
    my ($self,$c) = @_;
=pod    
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUserTag')
            ->search({'userid' => 'infinith4'},{
                prefetch => {'usertag_tag'},
                #rows => 6,
                order_by => {-asc => ['me.tagid']}
            })];
#=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkTag')
            ->search({},{
                prefetch => ['tag'],
                #rows => 6,
                order_by => {-asc => ['me.tagid']}
            })];

#=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUserTag')
            ->search({'me.userid' => 'infinith4'},{
                prefetch => ['usertag_tag'],
                #rows => 6,
                order_by => {-asc => ['me.tagid']}
            })];
#=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUserTag')
            ->search({'me.userid' => "infinith4"},{
                prefetch => ['tag'],
                rows => 6,
                order_by => {-desc => ['me.tagid']}
            })];
=cut
#=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUserTag')
            ->search({'userid' => "infinith4"},{
                order_by => {-asc => ['me.id']}
            })];
#=cut
=pod

    $c->stash->{list} = $c->model('BookmarkDB::BookmarkUserTag')->find('4');
=cut
}


sub prefetch01 :Local{
    my ($self,$c) = @_;

    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUser')
            ->search({'me.userid' => 'infinith4'},{
                prefetch => {'user_usertag' => 'tag'},
                #rows => 6,
                order_by => {-asc => ['tag.tag']}
            })];
=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkTag01')
            ->search({'userid' => 'infinity_th4'},{
                prefetch => ['tag01'],
                #rows => 6,
                order_by => {-asc => ['me.tagid']}
            })];
#=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkTag')
            ->search({},{
                prefetch => ['tag'],
                #rows => 6,
                order_by => {-asc => ['me.tagid']}
            })];

#=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUserTag')
            ->search({'me.userid' => 'infinith4'},{
                prefetch => ['usertag_tag'],
                #rows => 6,
                order_by => {-asc => ['me.tagid']}
            })];
#=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUserTag')
            ->search({'me.userid' => "infinith4"},{
                prefetch => ['tag'],
                rows => 6,
                order_by => {-desc => ['me.tagid']}
            })];
#=cut
#=pod
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUserTag')
            ->search({'userid' => "infinith4"},{
                order_by => {-asc => ['me.id']}
            })];
#=cut
#=pod

    $c->stash->{list} = $c->model('BookmarkDB::BookmarkUserTag')->find('4');
=cut
}

sub tag :Local {
    my ($self,$c) = @_;
    
}

sub release_note :Path("/release_note") {
    my ( $self, $c ) = @_;

    # Hello World
#    $c->response->body("Bookmark");
}

sub user : Local {
    my ($self,$c) = @_;
    #if($c->session->{name} == "infinity_th4" || $c->session->{name} == "infinith4"){
     if($c->session->{name} eq "infinity_th4"){
        $c->stash->{bookmarkuser} = [$c->model("BookmarkDB::BookmarkUser")->search({ },{ order_by => { -desc => 'created' }})];
        
    }
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
#    $c->response->redirect('/index');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

#my @apikey = Apikey::key("vps");
my @apikey = Apikey::key("local");

my $api = Hatena::API::Auth->new({
    api_key => $apikey[0],
    secret  => $apikey[1],
                                 });

sub login :Path('/hatena/login') {
    my ($self,$c) = @_;

    my $uri = $api->uri_to_login;
    #print Dumper $uri;
    print Dumper $uri->as_string;
    $c->response->redirect($uri->as_string);
    
}

sub auth :Path('/hatena/auth'){
    my ($self,$c) = @_;
    my $cert = $c->req->param('cert');
    my $user = $api->login($cert) or die "Couldn't login: " . $api->errstr;
    print Dumper $user;
    if(defined($user->name) && $user->name ne ''){
        $c->session->{name} = $user->name;
        $c->session->{image_url} = $user->image_url;
        $c->session->{thumbnail_url} = $user->thumbnail_url;
        #print Dumper $c->session;
        my $userid = $c->session->{name};
        my $exituser = 0; #userが登録されているか(登録されているなら1)
        if(defined($userid)){
            my $usercreate;
            #
            if(!$c->model('BookmarkDB::BookmarkUser')->find($c->session->{'name'})){
                $usercreate = $c->model('BookmarkDB::BookmarkUser')->update_or_new({
                    userid => $userid , #userid
                    created => strftime( "%Y-%m-%d %H:%M:%S" , localtime ),
                    lastaccess => strftime( "%Y-%m-%d %H:%M:%S" , localtime ),
                                                                                   }
                    );
            }else{
                $usercreate = $c->model('BookmarkDB::BookmarkUser')->update_or_new({
                    userid => $userid , #userid
                    lastaccess => strftime( "%Y-%m-%d %H:%M:%S" , localtime ),
                    
                                                                                   }
                    );
                $exituser = 1;
            }
            if($usercreate->in_storage){
                print "Not Modified\n";
            }else{
                $usercreate->insert;
                print "Insert Record\n";
                print "username:",$userid;
                
            }
        }
        
        if($exituser == 1){
            $c->response->redirect("/list");
        }else{
            $c->response->redirect("/bookmarksetting");
        }
    }else{
        $c->response->redirect("/");
    }
}

sub logout :Path('/hatena/logout') {
    my ($self,$c) = @_;
    $c->delete_session('logouted');
    print Dumper $c->session->{name};
    $c->response->redirect('/index');
}



#=pod
#全認証
#=pod
sub auto : Private {
    my ($self, $c) = @_;
    print Dumper $c->action->reverse;
    if ($c->action->reverse eq 'index' || $c->action->reverse eq '/hatena/login' || $c->action->reverse eq 'login' || $c->action->reverse eq 'auth' || $c->action->reverse eq 'release_note' || $c->action->reverse eq 'read/index'|| $c->action->reverse eq 'json/readdata') { return 1; } #read/indexはログインせずにアクセス(メールでリマインドしたURL)
    print Dumper $c->session->{name};
    if (!defined($c->session->{name})) {
        $c->response->redirect($c->uri_for('/index'));
        return 0;
    }
    
    return 1;
}
#=cut

#=cut
#過去にメールを送信した履歴
sub history :Local {
    my( $self,$c ) = @_;

    $c->stash->{history} = [$c->model("BookmarkDB::RemindHistory")
                                ->search({ 'bookmark.userid' => $c->session->{name} },{
                                    prefetch => ['bookmark'], #Schema/Result/RemindHistory にあるbelongs_to(bookmark ..のこと,RemindHistoryからbookmarkurlをkeyとしてBookmarkを参照.
                                    order_by => {-desc => ['me.sendtime'] }
    })];
}

sub search :Local{
    my ($self,$c)=@_;

    my $search_word = $c->request->query_params->{'search_word'}; #?search_word=[???]の部分を取得
    $c->stash->{search_word} = $search_word;
    my $page = $c->request->query_params->{"page"} || 1;
    $page = 1 unless $page;
    my $rows = 20;
    
    #print Dumper $search_word;
    if($search_word eq ''){$c->response->redirect("/list");}
    $c->stash->{bookmark} = [$c->model('BookmarkDB::Bookmark')
                         ->search_literal('bookmarkurl like ? AND description like ? ',("http://b.hatena.ne.jp/".$c->session->{name}."/%",'%'.$search_word.'%') ,
                                      {
                                          rows => $rows,
                                          page => $page,
                                          order_by => {-asc => ['bookmarkurl']}
                                   })];

    $c->stash->{tags} = [$c->model('BookmarkDB::BookmarkUser')
                             ->search({'me.userid' => $c->session->{name} },{
                                 prefetch => {'user_usertag' => 'tag'},
                                 order_by => {-asc => ['tag.tag']}
                             })];
    my $allnum = $c->model('BookmarkDB::Bookmark')
                         ->search_literal('bookmarkurl like ? AND description like ? ',("http://b.hatena.ne.jp/".$c->session->{name}."/%",'%'.$search_word.'%') ,
                                      {
                                          rows => $rows,
                                          page => $page,
                                          order_by => {-asc => ['bookmarkurl']}
                                   })->count;

    $c->stash->{allnum} = $allnum;
    my $maxpage = int($allnum / $rows ) + 1;

    $c->stash->{previouspage} = $page-1;
    $c->stash->{page} = $page;
    $c->stash->{nextpage} = $page + 1;
    $c->stash->{maxpage} = $maxpage;
=pod
    $c->stash->{bookmark} = [$c->model('BookmarkDB::Bookmark')
              ->search({'userid' => $c->session->{name},'description' => { 'LIKE' => '%'.$search_word.'%f' }},{
                  rows => $rows,
                  order_by => {-asc => ['bookmarkurl']}
              })];
=cut
    $c->stash->{template} = 'search.tt';
    $c->stash->{search_about} = $search_word;
}


sub listtest : Local {
    my ($self,$c) = @_;
    #if($c->session->{name} == "infinity_th4" || $c->session->{name} == "infinith4"){
    #$c->stash->{bookmark} = [$c->model("BookmarkDB::Bookmark")->search({ userid => 'infinith4'})];
    #print Data::Dumper [$c->model("BookmarkDB::Bookmark")->search({ userid => 'infinith4'})];
    $c->stash->{list} = [$c->model('BookmarkDB::BookmarkUser')
              ->search({'me.userid' => 'infinith4'},{
                  prefetch => {'user_usertag' => 'tag'},
                  #rows => 6,
                  order_by => {-asc => ['tag.tag']}
              })];

    my $query_tag = "あとで読む";
    $c->stash->{bookmark} = [$c->model('BookmarkDB::Bookmark')
              ->search({'userid' => 'infinith4','tag' => { 'LIKE' => '%['.$query_tag.']%'}},{
                  #rows => 6,
                  order_by => {-asc => ['bookmarkurl']}
              })];

    $c->stash->{template} = 'listtest.tt';
    
}

sub list :Local{
    my ( $self,$c ) = @_;
    $c->stash->{user} = $c->session;
    my $page = $c->request->query_params->{"page"} || 1;
    $page = 1 unless $page;
    my $rows = 20;
    my $query_tag =  $c->request->query_params->{"tag"} ; #/list?remind_tag=あとで読むなど指定すれば、
    my $userid = $c->session->{name};
    
    my $allnum;
    #tagを取得

    $c->stash->{tags} = [$c->model('BookmarkDB::BookmarkUser')
            ->search({'me.userid' => $userid },{
                prefetch => {'user_usertag' => 'tag'},
                #rows => 6,
                order_by => {-asc => ['tag.tag']}
            })];
    if(defined($query_tag)){ #query_tagのブックマーク
        $c->stash->{bookmark} = [$c->model('BookmarkDB::Bookmark')
                 ->search({'userid' => $userid ,'tag' => { 'LIKE' => '%['.$query_tag.']%'}},{
                     rows => $rows,
                     page => $page,
                     order_by => {-asc => ['bookmarkurl']}
                 })];
        $c->stash->{all} = 0;
    }else{
        $c->stash->{bookmark} = [$c->model('BookmarkDB::Bookmark')
                 ->search({ userid => $userid },
                      {
                          order_by => {-desc => 'bookmarkurl'},
                          rows => $rows,
                          page => $page
                      })];
        $allnum = $c->model('BookmarkDB::Bookmark')
            ->search({ userid => $c->session->{name} })->count;
        $c->stash->{all} = 1;
    }
    $c->stash->{allnum} = $allnum;
    my $maxpage = int($allnum / $rows ) + 1;

    $c->stash->{previouspage} = $page-1;
    $c->stash->{page} = $page;
    $c->stash->{nextpage} = $page + 1;
    $c->stash->{maxpage} = $maxpage;
    $c->stash->{query_tag} = "[".$query_tag."]";


}


sub bookmarksetting : Local{
    my ($self,$c) = @_;
    $c->stash->{settingok} = $c->request->query_params->{"settingok"}; #template側でsettingokが1なら,alertを出して,listにリダイレクトする.
    $c->stash->{findbookmarksetting} = $c->model('BookmarkDB::BookmarkSetting')->find($c->session->{'name'}); #get BookmarkSetting of user.
    $c->stash->{user} = $c->session; #login username.
    ##userが登録されているか(登録されているなら1)
    if($c->model('bookmarkdb::bookmarksetting')->find($c->session->{'name'})){
        $c->stash->{exituser} = 1;
    }
    #毎回タグを取ってきたら時間がかかりすぎる.dbをjson化し,ajaxで処理する
    #主なタグを10件取得,表示
    my @user = ($c->session->{'name'}); #ex.$c->session->{'name'} is 'infinity_th4'.
    my @bookmarkmaintags = Userdata::getmaintag(@user);
    $c->stash->{bookmarkmaintags} = \@bookmarkmaintags;
    
    #すべてのタグを取得,表示
    my $userid = $c->session->{'name'};
    my @bookmarkusertag = $c->model('BookmarkDB::BookmarkUserTag')->search({ userid => $userid})->get_column('tagid')->all; #get tagid og User's Bookmark.
    my @bookmarktag;
    foreach (@bookmarkusertag){
        push(@bookmarktag,$c->model('BookmarkDB::BookmarkTag')->search({ tagid => $_ })->get_column('tag')->all); #get tags from BookmarkTag.
    }
    $c->stash->{bookmarktags} = \@bookmarktag;
    if($c->req->method eq 'POST'){ #Push save button in a form.
        my $days = $c->request->body_params->{'days'};
        my $joindays;
        if (ref($days) eq '') {
            $joindays = $days;
        }else{
            $joindays = join ',', @$days;
        }
        my $tags = $c->request->body_params->{'remind_tag'};
        $tags =~ s/\]\[/\],\[/g;
        my @items = split /,/, lc($tags); #tagをすべて小文字にする
        #sort
        my @sortedarray = sort { $a cmp $b } @items;

        my %tmp;
        my @tag = grep(  !$tmp{$_}++, @sortedarray);
        my $tag = join "", @tag;
        my %setting = (
            userid => $c->session->{'name'},                        #username
            email => $c->request->body_params->{'email'},           #email
            remind_tag => $tag, #remind tag
            remind_num => $c->request->body_params->{'remind_num'}, #remind number
            days => $joindays,                                      #daysをカンマで区切る
            hour => $c->request->body_params->{'hour'},             #hour
            minute => $c->request->body_params->{'minute'},         #minute
            );
        my $bookmarksetting;
        if(!$c->model('BookmarkDB::BookmarkSetting')->find($c->session->{'name'})){ #BookmarkSetting にデータがなかったら.
            $bookmarksetting = $c->model('BookmarkDB::BookmarkSetting')->update_or_new({
                remind_tag => $setting{remind_tag},
                userid => $setting{userid},
                email => $setting{email},
                remind_num => $setting{remind_num},
                days => $setting{days},
                hour => $setting{hour},
                minute => $setting{minute},
                created => strftime( "%Y-%m-%d %H:%M:%S" , localtime ),
                updated => strftime( "%Y-%m-%d %H:%M:%S" , localtime ),
            });
        }else{
            $bookmarksetting = $c->model('BookmarkDB::BookmarkSetting')->update_or_new({
                remind_tag => $setting{remind_tag},
                userid => $setting{userid},
                email => $setting{email},
                remind_num => $setting{remind_num},
                days => $setting{days},
                hour => $setting{hour},
                minute => $setting{minute},
                updated => strftime( "%Y-%m-%d %H:%M:%S" , localtime ),
            });
        }

        if($bookmarksetting->in_storage){
            print "BookmarkSetting is not Modified\n";
        }else{
            $bookmarksetting->insert;
            print "Modified\n";
        }

        $c->response->redirect("/bookmarksetting?settingok=1");

    }
}


=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
