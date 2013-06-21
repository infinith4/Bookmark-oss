use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Bookmark';
use Bookmark::Controller::Ctrl::Attr;

ok( request('/ctrl/attr')->is_success, 'Request should succeed' );
done_testing();
