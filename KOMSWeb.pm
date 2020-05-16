package KOMSWeb;

use KOMSWeb::Proxy;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config MyProxy /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyProxy(KOMSWeb::Proxy->new);
}

sub Execute {
  my ($self,%args) = @_;
}

sub ProcessMessage {
  my ($self,%args) = @_;
}

1;
