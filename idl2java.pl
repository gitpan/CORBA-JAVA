#!/usr/bin/perl -w

use strict;
use CORBA::IDL::parser30;
use CORBA::IDL::symbtab;
# visitors
use CORBA::IDL::repos_id;
use CORBA::Java::name;
use CORBA::Java::literal;
use CORBA::Java::class;

my $parser = new Parser;
$parser->YYData->{verbose_error} = 1;		# 0, 1
$parser->YYData->{verbose_warning} = 1;		# 0, 1
$parser->YYData->{verbose_info} = 1;		# 0, 1
$parser->YYData->{verbose_deprecated} = 0;	# 0, 1 (concerns only version '2.4' and upper)
$parser->YYData->{symbtab} = new CORBA::IDL::Symbtab($parser);
my $cflags = '-D__idl2java';
if ($Parser::IDL_version lt '3.0') {
	$cflags .= ' -D_PRE_3_0_COMPILER_';
}
if ($^O eq 'MSWin32') {
	$parser->YYData->{preprocessor} = 'cpp -C ' . $cflags;
#	$parser->YYData->{preprocessor} = 'CL /E /C /nologo ' . $cflags;	# Microsoft VC
} else {
	$parser->YYData->{preprocessor} = 'cpp -C ' . $cflags;
}
$parser->getopts("hi:p:t:vx");
if ($parser->YYData->{opt_v}) {
	print "CORBA::JAVA $CORBA::JAVA::class::VERSION\n";
	print "CORBA::IDL $CORBA::IDL::node::VERSION\n";
	print "IDL $Parser::IDL_version\n";
	print "$0\n";
	print "Perl $] on $^O\n";
	exit;
}
if ($parser->YYData->{opt_h}) {
	use Pod::Usage;
	pod2usage(-verbose => 1);
}
$parser->YYData->{forward_constructed_forbidden} = 1;
$parser->Run(@ARGV);
$parser->YYData->{symbtab}->CheckForward();
$parser->YYData->{symbtab}->CheckRepositoryID();

if (exists $parser->YYData->{nb_error}) {
	my $nb = $parser->YYData->{nb_error};
	print "$nb error(s).\n"
}
if (        $parser->YYData->{verbose_warning}
		and exists $parser->YYData->{nb_warning} ) {
	my $nb = $parser->YYData->{nb_warning};
	print "$nb warning(s).\n"
}
if (        $parser->YYData->{verbose_info}
		and exists $parser->YYData->{nb_info} ) {
	my $nb = $parser->YYData->{nb_info};
	print "$nb info(s).\n"
}
if (        $parser->YYData->{verbose_deprecated}
		and exists $parser->YYData->{nb_deprecated} ) {
	my $nb = $parser->YYData->{nb_deprecated};
	print "$nb deprecated(s).\n"
}

if (        exists $parser->YYData->{root}
		and ! exists $parser->YYData->{nb_error} ) {
	$parser->YYData->{root}->visit(new CORBA::IDL::repositoryIdVisitor($parser));
	if (        $Parser::IDL_version ge '3.0'
			and $parser->YYData->{opt_x} ) {
		$parser->YYData->{symbtab}->Export();
	}
	$parser->YYData->{root}->visit(new CORBA::JAVA::nameVisitor($parser, $parser->YYData->{opt_p}, $parser->YYData->{opt_t}));
	$parser->YYData->{root}->visit(new CORBA::JAVA::literalVisitor($parser));
	$parser->YYData->{root}->visit(new CORBA::JAVA::name2Visitor($parser));
	$parser->YYData->{root}->visit(new CORBA::JAVA::classVisitor($parser));
}

__END__

=head1 NAME

idl2java - IDL compiler to language Java mapping

=head1 SYNOPSIS

idl2java [options] I<spec>.idl

=head1 OPTIONS

All options are forwarded to C preprocessor, except -h -i -v -x.

With the GNU C Compatible Compiler Processor, useful options are :

=over 8

=item B<-D> I<name>

=item B<-D> I<name>=I<definition>

=item B<-I> I<directory>

=item B<-I->

=item B<-nostdinc>

=back

Specific options :

=over 8

=item B<-h>

Display help.

=item B<-i> I<directory>

Specify a path for import (only for IDL version 3.0).

=item B<-p> "I<m1>=I<prefix1>;..."

Specify a list of prefix (gives full qualified Java package names).

=item B<-t> "I<m1>=I<new.name1>;..."

Specify a list of name translation (gives  full qualified Java package names).

=item B<-v>

Display version.

=item B<-x>

Enable export (only for IDL version 3.0).

=back

=head1 DESCRIPTION

B<idl2java> parses the given input file (IDL) and generates files that
following the IDL to Java Language Mapping Specification, v1.2.

B<idl2java> is a Perl OO application what uses the visitor design pattern.
The parser is generated by Parse::Yapp.

B<idl2java> needs a B<cpp> executable.

CORBA Specifications, including IDL (Interface Language Definition) and
JAVA Language Mapping are available on E<lt>http://www.omg.org/E<gt>.

=head1 SEE ALSO

cpp, L<idl2html>, L<idl2c>

=head1 COPYRIGHT

(c) 2002-2004 Francois PERRAD, France. All rights reserved.

This program and all CORBA::JAVA modules are distributed
under the terms of the Artistic Licence.

=head1 AUTHOR

Francois PERRAD, francois.perrad@gadz.org

=cut

