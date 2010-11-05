#!/usr/bin/env perl

use strict;
use warnings;

use Test::More qw/no_plan/;
use Test::Mojo;

package SomeService;

$SomeService::VERSION = '94530';

use base 'Clustericious::App';
use Clustericious::RouteBuilder;

get '/' => sub { shift->render_text("unprotected"); };

authenticate;

get '/sensitive' => sub { shift->render_text("sensitive stuff"); };

authorize 'kick';

get '/football' => sub { shift->render_text("success"); };

package main;
use Clustericious::Config;

my $t = Test::Mojo->new(app => "SomeService");

my $auth_url = $ENV{CLUSTERICIOUS_TEST_AUTH_URL};
if ($auth_url) {
    Clustericious::Config->new("SomeService")
      ->simple_auth( default => { url => $auth_url } );
}

$t->get_ok("/")->status_is(200)->content_like(qr/unprotected/, "got unprotected content");

my $port = $t->client->test_server;

$t->get_ok("/sensitive")->status_is(401);

SKIP: {
    skip "Define CLUSTERICIOUS_TEST_AUTH_URL to test simple auth", 8 unless $auth_url;
    $t->get_ok("http://elmer:fudd\@localhost:$port/sensitive")
        ->status_is(200)
        ->content_like(qr/sensitive stuff/);
    $t->get_ok("http://charliebrown:snoopy\@localhost:$port/football")
        ->status_is(200)
        ->content_like(qr/success/);
    $t->get_ok("http://elmer:fudd\@localhost:$port/football")->status_is(403);

}

1;

