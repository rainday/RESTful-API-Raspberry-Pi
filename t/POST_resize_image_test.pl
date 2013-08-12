#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use Data::Dumper;

my $uri = 'http://192.168.1.154/api/resize_image';
my $usr = 'test123';
my $pas = 'test123';
my $json = '{ "width":"100","image_url":"http://l.yimg.com/f/i/tw/hp/mh/12purple.gif" }';
my $ua = LWP::UserAgent->new();
my $req = HTTP::Request->new('POST', $uri);
$req->header( 'Content-Type'=>'application/json'  );
$req->content($json);
$req->authorization_basic('test123', 'test123');

my $content = $ua->request($req);

print STDERR Dumper($content);

1;
