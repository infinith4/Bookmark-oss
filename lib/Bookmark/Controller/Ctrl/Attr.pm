package Bookmark::Controller::Ctrl::Attr;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Bookmark::Controller::Ctrl::Attr - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Bookmark::Controller::Ctrl::Attr in Ctrl::Attr.');
}

sub path_attr :Path('/hoge-foo'){
    my ($self, $c ) = @_;
    $c->response->body('Path属性の例です');
}
sub mysetup : Chained('/') PathPart('') CaptureArgs(2) {
    my ($self, $c, @arg) = @_;
    $c->log->debug("in mysetup");
    $c->log->debug( $arg[0] );
    $c->log->debug( $arg[1] );
}                     
 
sub myaction : Chained('mysetup') PathPart('do_action') Args(1) {
    my ($self, $c, $arg) = @_;
    $c->log->debug("in myaction");
    $c->log->debug( $arg );
    $c->res->body(1);
}


sub chain_top :Chained('/') :PathPart('first') :CaptureArgs(0) {
    my ($self, $c) = @_;
    $c->stash->{body} = '<p>chaintop</p>';
}

sub chain_second :Chained('chain_top') :PathPart('second') :CaptureArgs(1) {
    my ($self, $c, $id ) = @_;
    $c->stash->{body} .= "<p>chain_second:${id} </p>";
}

sub chain_third :Chained('chain_second') :PathPart('third') {
    my ($self, $c) = @_;
    $c->stash->{body} .= '<p>chain_third</p>';
    $c->response->body($c->stash->{body});
}
=pod
sub chain_top :Chained('/') :PathPart('first') :CaptureArgs(0) {
# sub chain_top :Chained:PathPart('first') :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->stash->{body} = '<p>chain_topアクション</p>';
}

sub chain_second :Chained('chain_top') :PathPart('second') :CaptureArgs(1) {
  my ( $self, $c, $id ) = @_;
  $c->stash->{body} .= "<p>chain_secondアクション：${id} </p>";
#  my ( $self, $c) = @_;
#  my $id =$c->request->captures->[0];
#  $c->stash->{body} .= "<p>chain_secondアクション：${id} </p>";
}

sub chain_third :Chained('chain_second') :PathPart('third') {
  my ( $self, $c ) = @_;
  $c->stash->{body} .= '<p>chain_thirdアクション</p>';
  $c->response->body($c->stash->{body});
}

=cut

=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
