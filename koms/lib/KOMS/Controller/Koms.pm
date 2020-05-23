package KOMS::Controller::Koms;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use String::ShellQuote qw(shell_quote);

# This action will render a template
sub index {
  my $self = shift;
  $self->write_chunk
    (
     $self->render_to_string(msg => 'KOMS Web (KMax Object Manipulation System - Web Interface)'),
    );
  if ($self->param('a') eq 'radar') {
    $self->DoCommand
      (
       Command => "radar -y ".shell_quote($self->param('t')),
      );
  } elsif ($self->param('a') eq 'archive') {
    my $url = $self->AbsoluteURL
      (
       Loc => 'https://frdcsa.org/frdcsa',
       Rel => $self->param('t'),
      );
    $self->DoCommand
      (
       Command => "cd /var/lib/myfrdcsa/codebases/minor/debian-rulebase/documentation-test && wget -x -np ".shell_quote($url),
      );
  }
  $self->finish('');
}

sub DoCommand {
  my ($self,%args) = @_;
  $self->write_chunk
    (
     '<br>Running '.$self->param('a').'<br>',
    );
  print Dumper({Command => $args{Command}});
  my $result = `$args{Command} 2>&1`;
  $self->write_chunk
    (
     "<pre>$result</pre>",
    );
}

sub AbsoluteURL {
  my ($self,%args) = @_;
  if ($args{Rel} !~ /(ht|f)tps?:\/\//) {
    return $args{Loc}.'/'.$args{Rel};
  } else {
    return $args{Rel};
  }
}


1;
