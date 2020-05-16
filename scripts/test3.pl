#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Mojo::IOLoop::Server;
use Mojo::UserAgent;
use Mojo::Message::Response;
use Mojo::Message::Request;
use Mojo::Transaction::HTTP;
use Data::Dumper;

binmode STDOUT, ":encoding(UTF-8)";

my %buffer;

Mojo::IOLoop->server( {port => 3128} => sub {
    my ($loop, $stream, $client) = @_;

    $stream->on(
        read => sub {
            my ($stream, $chunk) = @_;

            my $buffer = $buffer{$client}{read_buffer} .= $chunk;

            if ($buffer =~ /^GET\s+|POST\s+|HEAD\s+(.*)\r\n\r\n$/i) {
                $buffer{$client}{read_buffer} = '';
                &handle_request($client,$stream,$buffer);
            }

            elsif ($buffer =~ /^CONNECT\s+(.*)\r\n\r\n$/i) {
                $buffer{$client}{read_buffer} = '';
                &handle_connect($stream,$buffer);
            }

            elsif($buffer{$client}{connection})
            {
                $buffer{$client}{read_buffer} = '';
                Mojo::IOLoop->stream($buffer{$client}{connection})->write($chunk);
            }

            if(length($buffer)>= 20 *1024 * 1024) {
                delete $buffer{$client};
                Mojo::IOLoop->remove($client);
                return;
            }
        });
});

sub handle_request{

    my($client,$stream,$chunk) = @_;

    my $request = Mojo::Message::Request->new;
    $request = $request->parse($chunk);

    my $ua = Mojo::UserAgent->new;
    my $tx = $ua->start( Mojo::Transaction::HTTP->new(req=>$request) );

    $stream->write( $tx->res->to_string );
}

sub handle_connect{
    my ($stream, $chunk) = @_;
    my $request = Mojo::Message::Request->new;
    my $ua = Mojo::UserAgent->new;

    $request = $request->parse($chunk);

    print Dumper($request);
}

Mojo::IOLoop->start;
