package KOMSWeb::Filter;

# AlleyOop::Proxy::Filter;

use Data::Dumper;
use HTML::Parser;
use Lingua::EN::Tagger;
use Net::Dict;
use File::Slurp qw(read_file);

my $phrasedict = {};
my @stream1;
my $site = "http://127.0.0.1:8081/koms";

my $tagger = Lingua::EN::Tagger->new(stem => 0);
my $p = HTML::Parser->new
  (
   api_version => 3,
   start_h => [ sub {push @stream1, [shift,2,shift]}, "tagname, attr" ],
   end_h => [ sub {push @stream1, [shift,3]}, "tagname" ],
   text_h => [ sub {push @stream1, [shift,1]}, "text" ],
   comment_h => [ sub {push @stream1, [shift,0]}, "text" ],
   default_h => [ sub {push @stream1, [shift,0]}, "text" ],
   unbroken_text => 1,
   utf8_mode => 1,
   marked_sections => 1,
  );

sub Analyze {
  my ($dataref,$htmlbuffer) = @_;
  $p->parse($htmlbuffer);
  $p->eof;
  my @stream2;
  foreach my $item (@stream1) {
    if ($item->[1] == 1) {
      push @stream2, Annotate(Text => $item->[0]);
    } elsif ($item->[1] == 2) {
      push @stream2, ProcessStart(Start => $item);
    } elsif ($item->[1] == 3) {
      push @stream2, ProcessEnd(End => $item);
    } else {
      push @stream2, $item->[0];
    }
  }
  my $c = read_file('/var/lib/myfrdcsa/codebases/independent/koms-web/template/footer.html');
  $$dataref = join("\n",@stream2).$c;
  @stream1 = ();
  @stream2 = ();
}

sub Annotate {
  my (%args) = @_;
  my $text = $args{Text};
  $text = AnnotateGitReferences(Text => $text);
  $text = AnnotatePDFReferences(Text => $text);
  # $text = AnnotateTextEntities(Text => $text);
  return $text;
}

sub AnnotateGitReferences {
  my (%args) = @_;
  my $text = $args{Text};
  my @items = $text =~ /(.*?)(https:\/\/(?:github.com|salsa.debian.org)\/[^\/]+\/[^\/]+\/?)(.?)/;
  my @results;
  if (@items) {
    while (@items) {
      my ($pre,$url,$post) = (shift @items,shift @items,shift @items);
      push @results, $pre.GetDropDown(Sigil => '[',Item => $url, TypeCoercion => 'Git Repo Inline').$url."]".$post;
    }
    $text = join('',@results);
  }
  return $text;
}

sub AnnotatePDFReferences {
  my (%args) = @_;
  my $text = $args{Text};
  my @items = $text =~ /(.*?)(https?:\/\/[^\/]+\/\S+\.pdf)(.?)/;
  my @results;
  if (@items) {
    while (@items) {
      my ($pre,$pdf,$post) = (shift @items,shift @items,shift @items);
      push @results, $pre.GetDropDown(Sigil => '[',Item => $pdf, TypeCoercion => 'PDF URL Inline').$post;
    }
    $text = join('',@results);
  }
  return $text;
}

sub AnnotateTextEntities {
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
	$a->[0] = GetDropDown(Sigil => '{', Item => $address, TypeCoercion => 'Phrase').($a->[0] || "");
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
  my $firstwave = join("",@stream);
  return $firstwave;
}

sub ProcessStart {
  my (%args) = @_;
  my $address;
  my $inner = '';
  my $closing = '';
  foreach my $key (sort keys %{$args{Start}->[2]}) {
    if ($key eq '/') {
      $closing = '/';
      next;
    }
    if ($key eq 'href') {
      $address = $args{Start}->[2]->{$key};
    }
    $inner .= ' '.$key.'="'.$args{Start}->[2]->{$key}.'"';
  }
  my $return = '';
  if ($address) {
    if ($address =~ /\.pdf$/i) {
      $return .= GetDropDown(Sigil => '[]', Item => $address, TypeCoercion => 'PDF URL Link');
    } else {
      $return .= GetDropDown(Sigil => '+', Item => $address, TypeCoercion => 'URL');
    }
  }
  $return .= '<'.$args{Start}->[0].$inner.$closing.'>';
  print Dumper({Args => \%args, Start => $return}) if $UNIVERSAL::debug;
  return $return;
}

sub ProcessEnd {
  my (%args) = @_;
  my $return = '</'.$args{End}->[0].'>';
  print Dumper({Args => \%args, End => $return}) if $UNIVERSAL::debug;
  return $return;
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

sub GetDropDown {
  my (%args) = @_;
  # my (Sigil => '{',Item => $url, TypeCoercion => 'Git Repo')
  return "<div class=\"dropdown\"><a class=\"dropbtn\" href=\"$site?t=$args{Item}\">$args{Sigil}</a><div class=\"dropdown-content\">".GetMenuForType(TypeCoercion => $args{TypeCoercion}, Item => $args{Item})."</div></div>";
}

sub GetMenuForType {
  my (%args) = @_;
  my @menu;
  # push @menu, GetMenuItem(Item => $args{Item}, Action => 'Cancel', Name => 'cancel');
  if ($args{TypeCoercion} eq "Git Repo Inline") {
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Process with RADAR', Name => 'radar');
  }
  if ($args{TypeCoercion} eq "PDF URL Inline") {
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Process with Sentinel', Name => 'sentinel');
  }
  if ($args{TypeCoercion} eq "Git Repo Link") {
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Process with RADAR', Name => 'radar');
  }
  if ($args{TypeCoercion} eq "PDF URL Link") {
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Process with Sentinel', Name => 'sentinel');
  }
  if ($args{TypeCoercion} eq "URL") {
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Inspect', Name => 'inspect');
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Archive URL Content', Name => 'archive');
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Archive URL Contents Recursively', Name => 'archive_recursive');
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Process with RADAR (for Metasites perhaps)', Name => 'radar');
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Process with radar-web-search', Name => 'radar_web_search');
    push @menu, GetMenuItem(Item => $args{Item}, Action => 'Convert to NLU-MF format', Name => 'nlu_mf');
  }
  return join('',@menu);
}

sub GetMenuItem {
  my (%args) = @_;
  return "<a href=\"$site?t=$args{Item}&a=$args{Name}\">$args{Action}</a>";
  # return "<a href=\"$site?t=$args{Item}&a=$args{Name}\">$args{Action} ($args{Item})</a>";
}

1;
