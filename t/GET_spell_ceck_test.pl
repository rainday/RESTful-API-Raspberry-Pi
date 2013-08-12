#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use Data::Dumper;

# Replace with any word that you would like to check
my $text = 'test2 test an apple, hi what\'s up bon';
# your raspberry pi ip
my $your_ip = '192.168.1.154';
my $uri = "http://$your_ip/api/spell_check?word=$text";
my $usr = 'test123';
my $pas = 'test123';
my $ua = LWP::UserAgent->new();
my $req = HTTP::Request->new('GET', $uri);
$req->authorization_basic('test123', 'test123');
my $content = $ua->request($req);

print STDERR Dumper($content);

1;
