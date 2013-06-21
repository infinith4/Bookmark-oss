#!/usr/bin/perl
use strict;
use warnings;

#Remind Bookmark
#This script is send mail from DB.

my @command = ('perl', 'schedule_sendmail.pl');

while(1){
    my $ret = system @command;
    if ($ret != 0) {
        print "code[$ret]\n";
    }
    sleep(59);
}

