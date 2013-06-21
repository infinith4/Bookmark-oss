use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Bookmark';
use Bookmark::Controller::Json;

ok( request('/json')->is_success, 'Request should succeed' );
done_testing();
