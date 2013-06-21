#!/usr/bin/perl

package Schedule::Sendmail;

use strict;
use warnings;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Transport::SMTP;
use Data::Dumper;
use Encode;
use URI::Escape;

sub sendbookmark{
    my ($docdatas) = shift;
    print ":::::RUN sendbookmark::::::\n";
    my $frommail = "reminder.asia\@gmail.com";
    my $frommailpassword = "?????????????????"; #secret
    my $content;
    my $num = @$docdatas;
    
    for (my $i = 1;$i<$num;$i++){
        if ($$docdatas[$i]->{'tag'} eq '[]'){
            my $tag = "[(タグ無し)]";
            $content = $content ."\n $tag [リマインド数:$$docdatas[$i]->{'reminded_num'},読んだ数:$$docdatas[$i]->{'read_num'}]\n $$docdatas[$i]->{'title'}\n"."http://localhost:4000/read?url=".uri_escape($$docdatas[$i]->{'bookmarkurl'})."&userid=".$$docdatas[0]->{'userid'}."&originalurl=".$$docdatas[$i]->{'originalurl'}."\n";
            #$content = $content ."\n $tag [リマインド数:$$docdatas[$i]->{'reminded_num'},読んだ数:$$docdatas[$i]->{'read_num'}]\n $$docdatas[$i]->{'title'}\n"."http://reminder.asia:4000/read?url=".uri_escape($$docdatas[$i]->{'bookmarkurl'})."&userid=".$$docdatas[0]->{'userid'}."&originalurl=".$$docdatas[$i]->{'originalurl'}."\n";
        }else{
            $content = $content ."\n $$docdatas[$i]->{'tag'} [リマインド数:$$docdatas[$i]->{'reminded_num'},読んだ数:$$docdatas[$i]->{'read_num'}]\n $$docdatas[$i]->{'title'}\n"."http://localhost:4000/read?url=".uri_escape($$docdatas[$i]->{'bookmarkurl'})."&userid=".$$docdatas[0]->{'userid'}."&originalurl=".$$docdatas[$i]->{'originalurl'}."\n";
            #$content = $content ."\n $$docdatas[$i]->{'tag'} [リマインド数:$$docdatas[$i]->{'reminded_num'},読んだ数:$$docdatas[$i]->{'read_num'}]\n $$docdatas[$i]->{'title'}\n"."http://reminder.asia:4000/read?url=".uri_escape($$docdatas[$i]->{'bookmarkurl'})."&userid=".$$docdatas[0]->{'userid'}."&originalurl=".$$docdatas[$i]->{'originalurl'}."\n";
        }
    }
    print "TO:",$$docdatas[0]->{'userid'},"\n";

    #foreach (@$docdatas){
    print "Sendmail:\n";
    #print "to:",$_->{'userid'},"\n";
    #my $title = $_->{'title'};
    my $mailcontent = "$$docdatas[0]->{'userid'} さんへ。Bookmark Reminderより、「$$docdatas[0]->{'remind_tag'}」タグのついたブックマークをお知らせします。\n\n$content\n\n-----------------------------------------------\nBookmark Reminder for Chrome 拡張をリリースしました☆彡(以下のURLよりご利用ください)\nhttps://chrome.google.com/webstore/detail/pkpfhjlmnffcplalkilbjiilnhpeokcg/publish-accepted?hl=ja\n\n配信を停止する(http://reminder.asia:4000/bookmarksetting)\n\n-----------------------------------------------\n - Bookmark Reminder -あなたの気になるをお知らせ-\n $frommail";
    print $mailcontent,"\n";
    #print $$hash{userid},"\n";
    #mail 送信
    my $encodemailcontent;
    if(($$docdatas[0]->{'email'} =~ /^([a-zA-Z0-9\.\-\/_]{1,})\@docomo.ne.jp/) || ($$docdatas[0]->{'email'} =~ /^([a-zA-Z0-9\.\-\/_]{1,})\@ezweb.ne.jp/)){
        $encodemailcontent = encode('shift_jis', decode_utf8($mailcontent));
    }else{
        $encodemailcontent = encode('utf-8', decode_utf8($mailcontent));
    }
    my $email = Email::Simple->create(
        header => [
            From    => '"Reminder"'." <".$frommail.">",
            To      => $$docdatas[0]->{'userid'}."さん"." <".$$docdatas[0]->{'email'}.">",#given
            Subject => "Bookmark Reminder",#given
        ],
        body => "$mailcontent",#given
        );

        my $transport = Email::Sender::Transport::SMTP->new({
        ssl  => 1,
        host => 'smtp.gmail.com',
        port => 465,
        sasl_username => $frommail,
        sasl_password => $frommailpassword
                                                            });
        eval { sendmail($email, { transport => $transport }); };             
        if ($@) { warn $@ }
    #}

}

1;

#&sendmail(@docdatas);
