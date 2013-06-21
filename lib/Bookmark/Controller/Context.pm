package Bookmark::Controller::Context;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Bookmark::Controller::Context - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Bookmark::Controller::Context in Context.');
}
=pod
sub log_basic :Local {
    my ($self,$c ) = @_;
    my $l = $c->log();
    $l->fatal('Fatal log');
    $l->error('Error log');
    $l->warn('Warn log');
    $l->info('Info log');
    $l->debug('Debug log');
    $c->response->body('ログはコンソールから確認してください');
    
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
