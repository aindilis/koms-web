package KOMSWeb::RPCXML;

use lib "/var/lib/myfrdcsa/codebases/independent/koms-web";

# /var/lib/myfrdcsa/codebases/independent/koms-web/KOMSWeb/Filter.pm

use KOMSWeb::Filter;

use Data::Dumper;

use Time::HiRes qw( time );
use RPC::XML::Server;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => 
  [

   qw / MyRPCXML WSHost WSPort StartTime /

  ];

sub init {
  my ($self,%args) = @_;
  $self->WSHost($args{WSHost} || "127.0.0.1");
  $self->WSPort($args{WSPort} || 10000);
}

sub Start {
  my ($self,%args) = @_;
  $args{TimeOut} ||= 0.01;
  $self->StartServer
    (
     TimeOut => $args{TimeOut},
    );
}

sub StartServer {
  my ($self,%args) = @_;
  $self->StartTime(time());
  $self->MyRPCXML
    (RPC::XML::Server->new
     (
      no_default => 1,
      host => $self->WSHost,
      port => $self->WSPort,
     ));

  $self->MyRPCXML->add_method
    ({
      name => "QueryAgent",
      version => "1.0",
      signature => [
      		    'array string',
      		    'array array',
      		   ],
      code => sub {
	my ($srv,$raw) = @_;
	my $data = $raw->[0];
	my $result;
	KOMSWeb::Filter::Analyze(\$result,$data);
	return $result;
      },

      help => "This is the WebService version of the QueryAgent
      method, that takes a message, sends it to it's destination, and
      waits for a reply, before sending that reply back.",

     });

  print Dumper({Methods => $self->MyRPCXML->list_methods});

  $self->MyRPCXML->add_default_methods;
  $self->MyRPCXML->server_loop();
}

1;
