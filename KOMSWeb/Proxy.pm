package KOMSWeb::Proxy;

use Data::Dumper;
use HTTP::Proxy;
use HTTP::Proxy::HeaderFilter::simple;
use HTTP::Proxy::BodyFilter::complete;
use HTTP::Proxy::BodyFilter::simple;
use HTTP::Proxy::BodyFilter::htmlparser;

use KOMSWeb::Mod::ALL;

# $ENV{'HTTP_PROXY'} = 'http://localhost:3128/';

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyProxy /

  ];

# sub init {
#   my ($self,%args) = @_;
#   my $proxy = HTTP::Proxy->new( port => 3128, host => '127.0.0.1' );
#   my $filter = HTTP::Proxy::BodyFilter::simple->new(sub { ${ $_[1] } =~ s/the/fucking the/g; });
#   $proxy->push_filter(response => $filter);
#   $self->MyProxy($proxy);
#   print "hwllo?\n";
#   $self->MyProxy->start;
#   print "hwllo?\n";
# }

sub init {
  my ($self,%args) = @_;
  # my $ua = LWP::UserAgent->new();
  # $ua->protocols_allowed(['https']);
  my $proxy = HTTP::Proxy->new
    (
     host                    => 'localhost',
     max_clients             => 100,
     max_keep_alive_requests => 100,
     port                    => 3128,
     # agent                   => $ua,
    );

  # my $filter1 = KOMSWeb::Mod::ALL->new();
  my $filter1 = HTTP::Proxy::BodyFilter::simple->new(sub { print STDERR Dumper(\@_) });
  $proxy->push_filter
    (
     # method                  => 'OPTIONS,GET,HEAD,POST,PUT,DELETE,TRACE,CONNECT',
     scheme                  => 'http,https',
     mime                    => '*/*',
     # request
     response => $filter1,
    );

  # my $filter2 = HTTP::Proxy::HeaderFilter::simple->new(sub { print STDERR Dumper($_[1]) });
  # $proxy->push_filter
  #   (
  #    method                  => 'OPTIONS,GET,HEAD,POST,PUT,DELETE,TRACE,CONNECT',
  #    scheme                  => 'http,https',
  #    mime                    => '*/*',
  #    request => $filter2,
  #   );

  $self->MyProxy($proxy);
  print "hwllo?\n";
  $self->MyProxy->start;
  print "hwllo?\n";
}

1;


