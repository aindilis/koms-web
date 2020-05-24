#!/usr/bin/perl -w

use lib "/var/lib/myfrdcsa/codebases/independent/koms-web";

# /var/lib/myfrdcsa/codebases/independent/koms-web/KOMSWeb/RPCXML.pm

use KOMSWeb::RPCXML;

my $xmlrpc = KOMSWeb::RPCXML->new();

$xmlrpc->Start();
