package Bookmark::Controller::Json;
use Moose;
use namespace::autoclean;
use Encode qw/ decode_utf8 /;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Bookmark::Controller::Json - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Bookmark::Controller::Json in Json.');
}

sub tagdata :Local {
    my ($self,$c) = @_;
 
    $c->stash->{usertag} = [
        map {
            $_ = { map { $_ = decode_utf8($_) } $_->get_columns }
        }
    $c->model('BookmarkDB::BookmarkUserTag')->search({'userid' => $c->session->{name} },{})
    ];
    $c->stash->{tag} = [
        map {
            $_ = { map { $_ = decode_utf8($_) } $_->get_columns }
        }
    $c->model('BookmarkDB::BookmarkTag')->all
    ];
    $c->forward('Bookmark::View::JSON');
    
}

sub readdata :Local { #Privateにすると,ajaxで取得できなくなる
    my ($self,$c) = @_;
    
    #my $userid = $c->request->body_params->{'userid'};
    #print "aaaaaaaaaaaaaaaaaaaaaa";
    #print $userid,"\n";
    my $userid = $c->request->query_params->{'userid'};
    #print $userid,"\n";
    #my $userid = "infinith4";
    $c->stash->{bookmarkread} = [
        map {
            $_ = { map { $_ = decode_utf8($_) } $_->get_columns }
        }
    $c->model('BookmarkDB::BookmarkRead')->search({'userid' => $userid },{})
    ];
    $c->forward('Bookmark::View::JSON');
    
}

sub test :Local {
    my ($self,$c) = @_;
    #print "aaaaaaaaaaaa\n";
    #print $c->request->query_params->{'userid'},"\n";
    #my $userid = $c->request->body_params->{'userid'};
    my $userid = $c->request->params->{'userid'};
    #my $userid = $c->request->param('userid');
    print $userid;
}
=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
