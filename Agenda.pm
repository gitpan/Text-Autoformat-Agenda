package Text::Autoformat::Agenda;

require 5.005_62;
use strict;
use warnings;
use diagnostics;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Text::Autoformat::Agenda ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.02';

our $depth;
our $incr;
our $content;


# Preloaded methods go here.
sub new {

  my $class   = shift;
  my %config = @_;

  my $self   = bless \%config, $class;
}

sub tab { "    " x (@_ ? $depth+$_[0] : $depth) }

sub verbose_add_content {
  warn sprintf "depth: %d adding: ((%s))\n", $depth, $_[1];
  $_[0] .= $_[1]
} 

sub proc_array {

  my $self = shift;

  local $incr;

  while (my ($key,$val) = splice @_,0, 2) {

    ++$incr;
    if (!ref($val)) {
      my $F="$self->{Dir}/$val";
      open F, $F or die "Couldnt open $F: $!";
      my $_content;
      while (<F>) {
	$_content .= sprintf "%s%s", tab(1), $_;
      }

      my $bullet = sprintf "%s%s. %s\n%s",
	tab, $incr, $key, $_content;
      verbose_add_content($content,$bullet);
      # $content .= $bullet;
    } else {
	my $bullet = sprintf "%s%s. %s\n",
	  tab, $incr, $key;
	++$depth;
	verbose_add_content($content,$bullet);
	$self->proc_array(@$val);
	--$depth;
	# $content .= $bullet;
    }
  }

  $content;
}

sub content {

  my $self = shift;

  my $body = $self->proc_array(@{$self->{Agenda}});

  "$self->{Title}\n\n$body";

}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Text::Autoformat::Agenda - Automated agenda creation from flat files

=head1 SYNOPSIS

### Your boss proclaimeth:

Subject: Status Report Reminder
Date: Fri, 2 Mar 2001 15:00:26 -0800 (PST)
From: Bigwig <bigwig@bigcompany.com>
To: lowly_nobody@bigcompany.com

Please send me status reports by end-of-day Friday and cc the CEO.

Use the following format:

 * Accomplishments in the past week

 * Plans for the coming week

   Include vacation and classes scheduled and keep them on the report
   until taken.

 * Issues/Problems
   Please date these and keep them on the report until closed.


 ### So then you crank out:
  
  use Text::Autoformat::Agenda; # requires Text::Autoformat
  use Date::Business # not required. just useful for my agendas

  my $d = new Date::Business(FORCE => 'next');

  my ($year,$month,$day) = ($d->image =~ /(.{4})(.{2})(.{2})/);

  my $pretty_date = "$month-$day-$year";

  my $agenda = Text::Autoformat::Agenda->new
    ( Dir   => '/home/tmbranno/status',
      Title => "Status report for the week ending $pretty_date",
      Agenda =>
       [
         "Accomplishments in the past week" => 'accomplishments.txt',
         "Plans for the next week"          =>
             [
               General   => 'plans.txt',
               Vacations => 'vacations.txt',
               Classes   => 'classes.txt'
             ],
         "Outstanding issues"               => 'issues.txt'
       ]
    );

  print $agenda->content;

 ### Resulting output:

 Status report for the week ending 03-02-2001

 1. Accomplishments in the past week
    * Checked in bug 1581160. Now, user contact information (ie. phone,
      email) shows up along with the user's responsibilities.
    * Cleaned up and submitted source code for bug # 1479086. Now, users
      can obtain patches via ftp.
    * Contacted R Cissi (68330) to have him reproduce bug #
      1652235. The result of interacting with him forced him to lower
      the priority of bug 1652235 because the complaint levied was
      lacking important related information.
    * Could not reproduce bug number 1618728. Closed.
    * Integreated Clark's criticisms into a re-submission of bug
      1631057, the bug concerning the ability to edit the text of
      obsoleted checkins.

 2. Plans for the next week
    3. General
        * Automatic generation of this report is hampered by a bizarre
          recursion bug!
        * Compress the .tar files in my directories automatically
    2. Vacations
        * None
    3. Classes
        * None
 3. Outstanding issues
    * Need the key for my left shelf.
    * Bcc'ed mail ends up in my INBOX. Would rather it be automatically
      filed somewhere
    * I would like to auto-file these ARU checkin messages I get.
    * Install xemacs -- problems doing this


=head1 DESCRIPTION

Text::Autoformat::Agenda, abbreviated T::A::G, is a module for
cranking out Agendas. It takes a directory of status report files and
a Perl arrayref indicating how the files are to be composed into an
agenda document and creates the agenda.

It runs the text through Text::Autoformat's format for readability.

=head1 BUGS

There is a very odd recursion bug in this module. Even when the module's
  debug output (sent to STDERR) claims that it is generating text which looks
  a certain way, when you actually look at STDOUT, the output is different.

=head1 AUTHOR

T. M. Brannon, tbone@cpan.org

=head1 SEE ALSO

perl(1).

=cut
