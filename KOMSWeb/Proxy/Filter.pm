package KOMSWeb::Proxy::Filter;

use Data::Dumper;
use HTML::Parser;
use Lingua::EN::Tagger;
use Net::Dict;
use PerlLib::HTMLConverter;

use base qw( HTTP::Proxy::BodyFilter::complete );

my $phrasedict = {};
my @stream1;

my $tagger = Lingua::EN::Tagger->new(stem => 0);
my $converter = PerlLib::HTMLConverter->new;
my $p = HTML::Parser->new
  (
   api_version => 3,
   text_h => [ sub {push @stream1, [shift,1]}, "text" ],
   comment_h => [ sub {push @stream1, [shift,0]}, "text" ],
   default_h => [ sub {push @stream1, [shift,0]}, "text" ],
   unbroken_text => 1,
   utf8_mode => 1,
   marked_sections => 1,
  );

my $htmlbuffer;

sub filter {
  my ( $self, $dataref, $message, $protocol, $buffer ) = @_;
  if (! defined $$buffer) {
    Analyze($dataref,$htmlbuffer);
  } else {
    $htmlbuffer .= $$dataref;
    $$dataref = "";
  }
}

sub Analyze {
  my ($dataref,$htmlbuffer) = @_;
  $p->parse($htmlbuffer);
  $p->eof;
  my @stream2;
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
  my $dict = Net::Dict->new("localhost");

  my %res = $tagger->get_max_noun_phrases($tagger->add_tags($text));
  # print Dumper({%res});
  foreach my $key (keys %res) {
    $phrasedict->{$key}++;
  }
  # now window over the text rewriting it
  my @triplets;
  my @tmp = $text =~ /(\W*)(\w+)(\W*)/g;
  while (@tmp) {
    push @triplets, [splice @tmp, 0,3];
  }
  my @window;
  my @gramsets;
  my $count = 0;
  my $tokens = [];
  my $k = 0;
  my @tmp1 = @triplets;
  while (@tmp1) {
    $tokens->[$k++] = [];
    my $item = shift @tmp1;
    push @window, [$item,$count++];
    if (@window > 5) {
      shift @window;
    }
    my @grams;
    foreach my $i (0..$#window) {
      my @tmp;
      foreach my $j ($i..$#window) {
	push @tmp, $window[$j];
      }
      push @grams, \@tmp;
    }
    push @gramsets, \@grams;
    if ($item->[2] !~ /^\s+$/) {
      @window = ();
    }

  }
  foreach my $gramset (@gramsets) {
    foreach my $gram (@$gramset) {
      my @train;
      foreach my $w (@$gram) {
	push @train, @{$w->[0]};
      }
      pop @train;
      my $example = join('', @train);
      if (DictionaryTest(Phrase => $example,Dict => $dict)) {
	my $wikiexample = $example;
	$wikiexample =~s/\s+/_/g;

	my $a = $tokens->[$gram->[0]->[1]];
	$a->[0] = "<a href=\"http://frdcsa.onshore.net/mediawiki/index.php/$wikiexample\">{</a>".($a->[0] || "");
	my $b = $tokens->[$gram->[$#gram]->[1]];
	$b->[1] .= "}";
      }
    }
  }

  my $i = 0;
  my @stream;
  foreach my $triplet (@triplets) {

    push @stream, $triplet->[0];
    push @stream, $tokens->[$i]->[0] if $tokens->[$i]->[0];
    push @stream, $triplet->[1];
    push @stream, $tokens->[$i]->[1] if $tokens->[$i]->[1];
    push @stream, $triplet->[2];
    ++$i;
  }
  return join("",@stream);
}

sub DictionaryTest {
  my %args = @_;
  if (1) {
    return exists $phrasedict->{lc($args{Phrase})};
  } else {
    $h = $args{Dict}->define($args{Phrase});
    return scalar @$h > 0;
  }
}

1;
