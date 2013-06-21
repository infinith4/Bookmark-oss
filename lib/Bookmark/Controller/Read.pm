package Bookmark::Controller::Read;
use Moose;
use namespace::autoclean;
use POSIX 'strftime';
use URI::Escape;
use CGI;
use Data::Dumper;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Bookmark::Controller::Read - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    #http://localhost:4000/read?url=http://b.hatena.ne.jp/infinith4/20121101%23bookmark-117750598&userid=[userid]
    my $url = $c->request->query_params->{'url'}; #?url=[???]の部分を取得 http://b.hatena.ne.jp/infinith4/20121101%23bookmark-117750598
    my $userid = $c->request->query_params->{'userid'}; #userid=[userid]の部分を取得 はてなにログインしているuserid
    my $originalurl = $c->request->query_params->{'originalurl'}; #originalurl=[originalurl]の部分を取得
    #print uri_escape("\#"),"\n"; #%23
    my $escape_url = uri_escape($url);
    if($userid && $escape_url =~ m|http%3A%2F%2Fb.hatena.ne.jp%2F[a-zA-Z0-9_-]+|){
        my $unescape_url = uri_unescape($url);
        my @read_nums;
        push(@read_nums,$c->model('BookmarkDB::BookmarkRead')->search({ userid => $userid, bookmarkurl => $url })->get_column('read_num')->all);
        $c->stash->{read_num} = $read_nums[0];
        my $read_num = $read_nums[0] + 1;
        my $read = $c->model('BookmarkDB::BookmarkRead')->update_or_new({
            userid => $userid,
            bookmarkurl => $url,
            read_num => $read_num,

        });
        if($read->in_storage){
            #$c->response->body("更新しました");
        } else {
            $read->insert();
            #$c->response->body("登録しました");
        }
        $c->response->redirect($originalurl);
        #$c->response->redirect("http://www.google.com");
    }else{
        $c->response->redirect("http://b.hatena.ne.jp/".$userid);
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
