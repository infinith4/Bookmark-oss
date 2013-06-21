#!/usr/bin/perl

use strict;
use warnings;


use File::Basename;
 use Jcode;
use MIME::Base64 qw(encode_base64);
 
 my $to_mail = 'infinith4@gmail.com';
 my $from_mail = 'infinity.th4@gmail.com';
 my $subject = '画像付きHTMLメール';
 my $mail_cmd = 'sendmail -t';
 
 my $image1 = "image1.jpg";
 my $image2 = "image2.jpg";
 
 my $contents = '
 <html><body>
 <h1>ＨＴＭＬでのメールです。</h1>
 <center>写真を送ります。２枚あります。</center><p>
 
 写真１
 <img src="cid:image1"><br>
 
 写真２
 <img src="cid:image2"><br>
 </body>
 </html>
 ';
 
 $contents = jcode($contents)->jis;
 
 my $header;
 $header = "From: " . jcode("$from_mail")->mime_encode . "\n";
 $header .= "To: " . jcode("$to_mail")->mime_encode . "\n";
 $header .= "Subject: " . jcode($subject)->mime_encode . "\n";
 $header .= "MIME-Version: 1.0\n";
 $header .= "Content-type: multipart/related; boundary=\"boundary-here--\";type=Text/HTML;\n";
 $header .= "Content-Transfer-Encoding: 7bit\n\n";
 
 $header .= "--boundary-here--\n";
 $header .= "Content-type: Text/HTML; charset=ISO-2022-JP\n\n";
 
 my $buf;
 my $footer = "\n";
foreach my $im ($image1,$image2){
     my ($body, $path, $ext) = fileparse($im, '\.\w+');
     my %type = (jpg => 'JPEG',
                 gif => 'GIF',
                 png => 'PNG');
     $ext =~ s/\.//;
     $footer .= "--boundary-here--\n";
     $footer .= "Content-Disposition: attachment; filename=\"$im\"\n";
     $footer .= "Content-Type: IMAGE/$type{$ext}\n";
     $footer .= "Content-ID: $body\n";
     $footer .= "Content-Transfer-Encoding: BASE64\n\n";
     open(FILE, "< $im");
     while (read(FILE, $buf, 60*57)) {
            $footer .= encode_base64($buf);
        }
     close(FILE);
 }
 
if (open(SMAIL, "| $mail_cmd")){
        print SMAIL $header;
        print SMAIL $contents;
        print SMAIL $footer;
        close(SMAIL);
    } else {
        &error("メールコマンドが実行できません。<br>$mail_cmdが正しいか確認してください。");
    }
 
 prnit "Content-Type: text/html\n\n";
 print "送信しました。";


