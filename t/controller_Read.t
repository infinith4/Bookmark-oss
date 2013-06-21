use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Bookmark';
use Bookmark::Controller::Read;

ok( request('/read')->is_success, 'Request should succeed' );
done_testing();
