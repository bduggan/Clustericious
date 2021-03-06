package Clustericious::HelloWorld;

use strict;
use warnings;
use Mojo::Base 'Clustericious::App';
use Clustericious::RouteBuilder qw/Clustericious::HelloWorld/;

# ABSTRACT: Clustericious hello world application
# VERSION

=head1 SYNOPSIS

 % MOJO_APP=Clustericious::HelloWorld clustericious start

=head1 DESCRIPTION

A very simple example Clustericious application intended for testing only.

=head1 SUPER CLASS

L<Clustericious::App>

=head1 SEE ALSO

L<Clustericious>, L<Mojo::HelloWorld>

=cut

BEGIN {
    $ENV{LOG_LEVEL} = 'FATAL';
}

any '/*foo' => {foo => '', text => 'Clustericious is working!'};

1;
