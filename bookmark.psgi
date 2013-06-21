use strict;
use warnings;

use Bookmark;

my $app = Bookmark->apply_default_middlewares(Bookmark->psgi_app);
$app;

