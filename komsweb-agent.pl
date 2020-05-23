#!/usr/bin/perl -w

use Getopt::Declare;
use UniLang::Agent::Agent;
use UniLang::Util::Message;

use lib "/var/lib/myfrdcsa/codebases/independent/koms-web";
use KOMSWeb::Filter;

use Data::Dumper;

$specification = "
	-u [<host> <port>]	Use this Host and Port for UniLang (but do not start)

	-n <name>		The echo agent's name
";

my $conf = new Getopt::Declare($specification);

my $agent = UniLang::Agent::Agent->new
  (
   Name => "KOMSWeb",
   ReceiveHandler => \&Receive,
   # Debug => 1,
  );
$agent->DoNotDaemonize(1);

sub Receive {
  my %args = @_;
  # print Dumper({Jeez => $args{Message}});
  my $contents = $args{Message}->Contents;
  if ($contents =~ /^(quit|exit)$/) {
    $agent->Deregister;
    exit(0);
  } else {
    my $data = $args{Message}->Data->{KOMSWebData};
    my $result;
    KOMSWeb::Filter::Analyze(\$result,$data);
    $agent->SendContents
      (
       Receiver => $args{Message}->Sender,
       Contents => $contents,
       Data => {
		'_DoNotLog' => 1,
		'KOMSWebData' => $result,
	       },
      );
  }
}

sub Start {
  my $host = defined $conf->{-u}->{'<host>'} ? $conf->{-u}->{'<host>'} : "localhost";
  my $port = defined $conf->{-u}->{'<port>'} ? $conf->{-u}->{'<port>'} : "9000";
  $agent->Register
    (
     Host => $host,
     Port => $port,
    );
  $agent->Listen;
}

Start;
