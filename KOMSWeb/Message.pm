package KOMSWeb::Message;

use Data::Dumper;
use utf8;
use XML::Dumper;
use XML::Twig;

# use XML::Dumper;
# USE XML::Dumper HERE TO IMPLEMENT TO AND FROM XML FOR MESSAGES

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / ID Sender Receiver Date Contents Data MyXMLDumper DataFormat Debug / ];

our $debug = 0;

sub init {
  my ($self, %args) = (shift,@_);
  $self->MyXMLDumper
    (XML::Dumper->new());
  if (exists $args{Raw}) {
    %args = $self->Parse(%args);
  }
  $self->ID($args{ID} || $self->GetID);
  $self->Sender($args{Sender});
  $self->Date($args{Date} || $self->GetDate);
  $self->Receiver($args{Receiver});
  $self->Contents($args{Contents});
  $self->Data($args{Data} || {});
  $self->DataFormat($args{DataFormat} || "Perl");
  if ($args{Message}) {
    my $m = $args{Message};
    if (ref $m =~ /KOMSWeb::Message/) { # should really have
                                              # something that can
                                              # handle derived classes
                                              # here
      # copy this message
      $self->ID($message->GetID);
      $self->Sender($message->Sender);
      $self->Date($m->Date);
      $self->Receiver($m->Receiver);
      $self->Contents($m->Contents);
      $self->Data($m->Data);
    }
  }
}

sub GetID {
  my ($self, %args) = (shift,@_);
  return "0";
}

sub GetDate {
  my ($self, %args) = (shift,@_);
  my $date = `date` || "";
  chomp $date;
  return $date;
}

sub Parse {
  my ($self, %args) = (shift,@_);
  my $t = XML::Twig->new(pretty_print => 'indented');
  my %parsed;
  print STDERR Dumper($args{Raw}) if $debug;
  $t->parse($args{Raw});
  my $root = $t->root;
  $root->set_gi( 'message');

  $parsed{Id} = $root->first_child('id')->text;
  $parsed{Sender} = $root->first_child('sender')->text;
  $parsed{Receiver} = $root->first_child('receiver')->text;
  $parsed{Date} = $root->first_child('date')->text;
  $parsed{Contents} = $root->first_child('contents')->text;

  utf8::decode($parsed{Id});
  utf8::decode($parsed{Sender});
  utf8::decode($parsed{Receiver});
  utf8::decode($parsed{Date});
  utf8::decode($parsed{Contents});

  my $data = $root->first_child('data')->text;

  utf8::decode($data);

  if ($data) {
    if ($data =~ /^\$VAR1/) {
      $VAR1 = undef;
      # $data = XML::DeDumper($data);
      print STDERR "DATA: <".$data.">\n" if $debug;
      eval $data;
      eval $data;
      $parsed{Data} = $VAR1;
      $VAR1 = undef;
    } else {
      $parsed{Data} = $self->MyXMLDumper->xml2pl
	($data);
    }
  }
  return %parsed;
}

sub Generate {
  my ($self, %args) = (shift,@_);
  # prints in XML form, i.e.
  my $twig = XML::Twig->new(pretty_print => 'indented');
  my $message = XML::Twig::Elt->new('message');

  my $id = XML::Twig::Elt->new('id');
  my $idtext = 1;
  utf8::encode($idtext);
  $id->set_text($idtext);
  $id->paste('last_child', $message);

  my $sender = XML::Twig::Elt->new('sender');
  my $sendertext = $self->Sender;
  utf8::encode($sendertext);
  $sender->set_text($sendertext);
  $sender->paste('last_child', $message);

  my $receiver = XML::Twig::Elt->new('receiver');
  my $receivertext = $self->Receiver;
  utf8::encode($receivertext);
  $receiver->set_text($receivertext);
  $receiver->paste('last_child', $message);

  my $date = XML::Twig::Elt->new('date');
  my $datetext = $self->Date;
  utf8::encode($datetext);
  $date->set_text($datetext);
  $date->paste('last_child', $message);

  my $contents = XML::Twig::Elt->new('contents');
  my $contentstext = $self->Contents || "";
  utf8::encode($contentstext);
  $contents->set_text($contentstext);
  $contents->paste('last_child', $message);

  my $data = XML::Twig::Elt->new('data');
  my $datatext;
  if ($self->DataFormat eq "Perl") {
    my $temp1 = $Data::Dumper::Purity;
    my $temp2 = $Data::Dumper::Deepcopy;
    $Data::Dumper::Purity = 1;
    $Data::Dumper::Deepcopy = 1;
    $datatext = Dumper($self->Data || {});
    $Data::Dumper::Purity = $temp1;
    $Data::Dumper::Deepcopy = $temp2;
  } elsif ($self->DataFormat eq "PerlXML") {
    $datatext = $self->MyXMLDumper->pl2xml( $self->Data || {});
  }
  utf8::encode($datatext);
  $data->set_text($datatext);
  $data->paste('last_child', $message);

  $message->sprint;
}

1;

# $data->set_text(XML::Dumper($self->Data || {}));
