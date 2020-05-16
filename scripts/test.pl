#!/usr/bin/perl -w

use HTTP::Proxy;
use HTTP::Proxy::HeaderFilter::simple;
use HTTP::Proxy::BodyFilter::simple;
use Data::Dumper;
use strict;
use warnings;

my $proxy = HTTP::Proxy->new(
			     port => 3128, max_clients => 100, max_keep_alive_requests => 100
			    );

my $hfilter = HTTP::Proxy::HeaderFilter::simple->new(
						     sub {
						       my ( $self, $headers, $message ) = @_;
						       print STDERR "headers", Dumper($headers);
						     }
						    );

my $bfilter = HTTP::Proxy::BodyFilter::simple->new(
						   filter => sub {
						     my ( $self, $dataref, $message, $protocol, $buffer ) = @_;
						     print STDERR "dataref", Dumper($dataref);
						   }
						  );

$proxy->push_filter( response => $hfilter); #header dumper
$proxy->push_filter( response => $bfilter); #body dumper
$proxy->start;

