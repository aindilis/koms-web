#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use HTTP::Proxy;
use HTTP::Proxy::BodyFilter::complete;
use HTTP::Proxy::BodyFilter::simple;
use JSON::XS     qw( decode_json );
use Data::Dumper qw( Dumper );

my $proxy = HTTP::Proxy->new(
    port                     => 3128,
    max_clients              => 100,
    max_keep_alive_requests  => 100,
);

my $filter = HTTP::Proxy::BodyFilter::simple->new(
    sub {
        my ( $self, $dataref, $message, $protocol, $buffer ) = @_;
        return unless $$dataref;
        my $content_type = $message->headers->content_type or return;
        say "\nContent-type: $content_type";
        my $data = decode_json( $$dataref );
        say Dumper( $data );
    }
);

$proxy->push_filter(
    method   => 'GET',
    mime     => 'application/json',
    response => HTTP::Proxy::BodyFilter::complete->new,
    response => $filter
		   );

$proxy->start();
