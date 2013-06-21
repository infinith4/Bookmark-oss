package Bookmark;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory
use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Session
    Session::Store::File
    Session::State::Cookie
    Authentication
    Session::PerUser
    FillInForm
    Unicode
/;
use Catalyst::Log::Log4perl;
=pod
    FormValidator::Simple
    FormValidator::Simple::Auto
=cut

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in bookmark.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.
# load plugin and setup

    
    # in controller
    # redirect login url

__PACKAGE__->config(
    name => 'Bookmark',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    #enable_catalyst_header => 1, # Send X-Catalyst header
    ENCODING => 'UTF-8',
    default_view => 'TT',
    TEMPLATE_EXTENSION => '.tt',
    enable_catalyst_header => 1, # Send X-Catalyst header
    'Plugin::Session' => {
        expires => 7200,
        storage => '/tmp/Bookmark/session_data',
        namespace => 'Bookmark',
        cookie_expires => 0,
        verify_address => 1,
        verify_user_agent => 1,
    }

    );
=pod
    'Plugin::Session' => {
        expires => 1800,
    },
    'Plugin::Authentication' => {
        default => {
            credential => {
                class => 'Password',
                password_field => 'passwd',
                password_type   => 'hashed',
                password_hash_type => 'MD5',
            },
            store => {
                class => 'DBIx::Class',
                user_model => 'BookmarkDB::User',
                use_userdata_from_session => 1,
                role_relation => 'roles',
                role_field => 'role',
                # role_column => 'roles',
                # ignore_fields_in_find => ['unam'],
            }
        }
    },
=cut

# Start the application
__PACKAGE__->setup();


=head1 NAME

Bookmark - Catalyst based application

=head1 SYNOPSIS

    script/bookmark_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Bookmark::Controller::Root>, L<Catalyst>

=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
