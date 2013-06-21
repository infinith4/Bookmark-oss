use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Bookmark';
use Bookmark::Controller::Context;

ok( request('/context')->is_success, 'Request should succeed' );
done_testing();
