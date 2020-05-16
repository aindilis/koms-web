package KOMSWeb::Mod::ALL;

use Data::Dumper;
$Data::Dumper::deepcopy = 1;
use HTML::Parser;
use System::Apertium;
use HTTP::Proxy::BodyFilter;
use Net::Dict;


use base qw( HTTP::Proxy::BodyFilter::complete );

my @stream1;

my $p = HTML::Parser->new
  (
   api_version => 3,
   text_h => [ sub {push @stream1, [shift,1]}, "text" ],
   comment_h => [ sub {push @stream1, [shift,0]}, "text" ],
   default_h => [ sub {push @stream1, [shift,0]}, "text" ],
   # unbroken_text => 1,
   # utf8_mode => 1,
   # marked_sections => 1,
  );

my $htmlbuffer;

sub filter {
  my ( $self, $dataref, $message, $protocol, $buffer ) = @_;
  print Dumper
    ({
      Self => $self,
      DataRef => $dataref,
      Message => $message,
      Protocol => $protocol,
      Buffer => $buffer,
     });
  if (! defined $$buffer) {
    print STDERR "hi\n";
    Analyze($dataref,$buffer);
  } else {
    $htmlbuffer .= $$dataref;
    $$dataref = "";
  }
}

sub Analyze {
  my ($dataref,$htmlbuffer) = @_;
  print Dumper({DataRef => $dataref});
  $p->parse($htmlbuffer);
  $p->eof;
  my @stream2;
  print Dumper(\@stream1);
  foreach my $item (@stream1) {
    if ($item->[1]) {
      push @stream2, Annotate(Text => $item->[0]);
    } else {
      push @stream2, $item->[0];
    }
  }
  $$dataref = join("\n",@stream2);
  @stream1 = ();
  @stream2 = ();
}

sub Annotate {
  my (%args) = @_;
  my $text = $args{Text};
  return "WTF"; #$text;
}

1;
