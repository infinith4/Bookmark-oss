package Bookmark::View::TT;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

Bookmark::View::TT - TT View for Bookmark

=head1 DESCRIPTION

TT View for Bookmark.

=head1 SEE ALSO

L<Bookmark>

=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
