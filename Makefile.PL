use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'          => 'CORBA::JAVA',
    'VERSION_FROM'  => 'class.pm',
    'ABSTRACT'      => 'IDL compiler to JAVA (idlj clone)',
    'PREREQ_PM'     => {
                        'CORBA::IDL::node'          => 2.40,
                        'CORBA::XMLSchemas::xsd'    => 0,
    },
    'PM'            => {
                        'class.pm'      => '$(INST_LIBDIR)/JAVA/class.pm',
                        'literal.pm'    => '$(INST_LIBDIR)/JAVA/literal.pm',
                        'name.pm'       => '$(INST_LIBDIR)/JAVA/name.pm',
                        'xml.pm'        => '$(INST_LIBDIR)/JAVA/xml.pm',
    },
    'EXE_FILES'     => ['idl2java.pl', 'idl2javaxml.pl'],
    'AUTHOR'        => "Francois PERRAD (francois.perrad\@gadz.org)",
    'dist'          => {
                        'COMPRESS'      => 'gzip',
                        'SUFFIX'        => '.gz',
    },
);
