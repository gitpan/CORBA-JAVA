use strict;
use UNIVERSAL;

#
#			Interface Definition Language (OMG IDL CORBA v3.0)
#
#			IDL to Java Language Mapping Specification, Version 1.1 June 2001
#

package JavaNameVisitor;

# builds $node->{java_name} and $node->{java_package}

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);
	my($parser) = @_;
	$self->{key} = 'java_name';
	$self->{srcname} = $parser->YYData->{srcname};
	$self->{symbtab} = $parser->YYData->{symbtab};
	$self->{java_keywords} = {
		# The keywords in the Java Language :
		# (from the Java Language Specification 1.0 First Edition, Section 3.9)
		'abstract'			=> 1,
#IDL	'boolean'			=> 1,
		'break'				=> 1,
		'byte'				=> 1,
#IDL	'case'				=> 1,
		'catch'				=> 1,
#IDL	'char'				=> 1,
		'class'				=> 1,
#IDL	'const'				=> 1,
		'continue'			=> 1,
#IDL	'default'			=> 1,
		'do'				=> 1,
#IDL	'double'			=> 1,
		'else'				=> 1,
		'extends'			=> 1,
		'final'				=> 1,
		'finally'			=> 1,
#IDL	'float'				=> 1,
		'for'				=> 1,
		'goto'				=> 1,
		'if'				=> 1,
		'implements'		=> 1,
		'import'			=> 1,
		'instanceof'		=> 1,
		'int'				=> 1,
#IDL	'interface'			=> 1,
#IDL	'long'				=> 1,
		'native'			=> 1,
		'new'				=> 1,
		'package'			=> 1,
		'private'			=> 1,
		'protected'			=> 1,
		'public'			=> 1,
		'return'			=> 1,
#IDL	'short'				=> 1,
		'static'			=> 1,
		'super'				=> 1,
#IDL	'switch'			=> 1,
		'synchronized'		=> 1,
		'this'				=> 1,
		'throw'				=> 1,
		'throws'			=> 1,
		'transcient'		=> 1,
		'try'				=> 1,
#IDL	'void'				=> 1,
		'volatile'			=> 1,
		'while'				=> 1,
		# additionnal Java constant
#IDL	'true'				=> 1,
#IDL	'false'				=> 1,
		'null'				=> 1,
		# methods on java.lang.Object
		# (from the Java Language Specification 1.0 First Edition, Section 20.1)
		'clone'				=> 1,
		'equals'			=> 1,
		'finalize'			=> 1,
		'getClass'			=> 1,
		'hashCode'			=> 1,
		'notify'			=> 1,
		'notifyAll'			=> 1,
		'toString'			=> 1,
		'wait'				=> 1
	};
	return $self;
}

sub _get_defn {
	my $self = shift;
	my($defn) = @_;
	if (ref $defn) {
		return $defn;
	} else {
		return $self->{symbtab}->Lookup($defn);
	}
}

sub _get_name {
	my $self = shift;
	my($node) = @_;
	my $name = $node->{idf};
	$name =~ s/^_get_//;
	$name =~ s/^_set_//;
	return "_" . $name if (exists $self->{java_keywords}->{name});
	return "_" . $name if ($name =~ /Helper$/);
	return "_" . $name if ($name =~ /Holder$/);
	return "_" . $name if ($name =~ /Operations$/);
	return "_" . $name if ($name =~ /POA$/);
	return "_" . $name if ($name =~ /Package$/);
	return $name;
}

sub _get_pkg {
	my $self = shift;
	my($node) = @_;
	my $pkg = $node->{full};
	$pkg =~ s/::[0-9A-Z_a-z]+$//;
	return '' unless ($pkg);
	my $defn = $self->{symbtab}->Lookup($pkg);
	if (	   $defn->isa('StructType')
			or $defn->isa('UnionType')
			or $defn->isa('ExceptionType') ) {
		$pkg =~ s/::[0-9A-Z_a-z]+$//;
	}
	return '' unless ($pkg);
	my $package = '';
	$pkg =~ s/^:://;
	foreach (split /::/, $pkg) {
		if (exists $self->{java_keywords}->{$_}) {
			$package .= "._" . $_;
		} else {
			if      (/Helper$/) {
				$package .= "._" . $_;
			} elsif (/Holder$/) {
				$package .= "._" . $_;
			} elsif (/Operations$/) {
				$package .= "._" . $_;
			} elsif (/POA$/) {
				$package .= "._" . $_;
			} elsif (/Package$/) {
				$package .= "._" . $_;
			} else {
				$package .= "." . $_;
			}
		}
	}
	$package =~ s/^\.//;
	if (       (   $node->isa('StructType')
				or $node->isa('UnionType')
				or $node->isa('ExceptionType'))
			and $defn->isa('BaseInterface') ) {
		$package .= "Package";
	}
	return $package;
}

sub _get_Name {
	my $self = shift;
	my($node) = @_;
	if ($node->{java_package}) {
		return $node->{java_package} . "." . $node->{java_name};
	} else {
		return $node->{java_name};
	}
}

sub _get_stub {
	my $self = shift;
	my($node) = @_;
	if ($node->{java_package}) {
		return $node->{java_package} . "._" . $node->{java_name} . "Stub";
	} else {
		return "_" . $node->{java_name} . "Stub";
	}
}

#
#	3.5		OMG IDL Specification
#

sub visitNameSpecification {
	my $self = shift;
	my($node) = @_;
	foreach (@{$node->{list_export}}) {
		$self->{symbtab}->Lookup($_)->visitName($self);
	}
}

#
#	3.7		Module Declaration
#

sub visitNameModules {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	foreach (@{$node->{list_export}}) {
		$self->{symbtab}->Lookup($_)->visitName($self);
	}
}

#
#	3.8		Interface Declaration
#

sub visitNameBaseInterface {
	my $self = shift;
	my($node) = @_;
	return if (exists $node->{java_package});
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_Name} = $self->_get_Name($node);
	$node->{java_stub} = $self->_get_stub($node);
	$node->{java_holder} = $node->{java_Name} . "Holder";
	$node->{java_init} = "null";
	$node->{java_read} = $node->{java_Name} . "Helper.read (is)";
	$node->{java_write} = $node->{java_Name} . "Helper.write (os, ";
	$node->{java_type_code} = $node->{java_Name} . "Helper.type ()";
	foreach (@{$node->{list_export}}) {
		$self->{symbtab}->Lookup($_)->visitName($self);
	}
}

#
#	3.9		Value Declaration
#

sub visitNameStateMember {
	my $self = shift;
	my($node) = @_;
	$self->_get_defn($node->{type})->visitName($self);
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_Name} = $self->_get_Name($node);
	# TODO
}

sub visitNameInitializer {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_Name} = $self->_get_Name($node);
	foreach (@{$node->{list_param}}) {
		$_->visitName($self);			# parameter
	}
}

#
#	3.10	Constant Declaration
#

sub visitNameConstant {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	my $type = $self->_get_defn($node->{type});
	my $defn;
	my $pkg = $node->{full};
	$pkg =~ s/::[0-9A-Z_a-z]+$//;
	$defn = $self->{symbtab}->Lookup($pkg) if ($pkg);
	if ( defined $defn and $defn->isa('BaseInterface') ) {
		$node->{java_Name} = $self->_get_Name($node);
	} else {
		$node->{java_Name} = $self->_get_Name($node) . ".value";
	}
#	$self->_get_defn($node->{type})->visitName($self);
	$type->visitName($self);
}

sub visitNameExpression {
	# empty
}

#
#	3.11	Type Declaration
#

sub visitNameTypeDeclarator {
	my $self = shift;
	my($node) = @_;
	if (exists $node->{modifier}) {		# native
		$node->{java_package} = $self->_get_pkg($node);
		$node->{java_name} = $self->_get_name($node);
		$node->{java_Name} = $self->_get_Name($node);
	} else {
		return if (exists $node->{java_package});
		my $type = $self->_get_defn($node->{type});
		if (exists $node->{array_size}) {
			$type->visitName($self);
			$node->{java_package} = $self->_get_pkg($node);
			$node->{java_name} = $self->_get_name($node);
			$node->{java_Name} = $self->_get_Name($node);
			$node->{java_holder} = $node->{java_Name} . "Holder";
			$node->{java_init} = "null";
			$node->{java_read} = $node->{java_Name} . "Helper.read (is)";
			$node->{java_write} = $node->{java_Name} . "Helper.write (os, ";
			$node->{java_type_code} = $node->{java_Name} . "Helper.type ()";
		} else {
			if ($type->isa('SequenceType')) {
				$type->{repos_id} = $node->{repos_id};
				$type->visitName($self, $self->_get_name($node));
				$node->{java_package} = $self->_get_pkg($node);
				$type = $self->_get_defn($type->{type});
				$node->{java_name} = $type->{java_name} . "[]";
				while ($type->isa('SequenceType')) {
					$node->{java_name} .= "[]";
					$type = $self->_get_defn($type->{type});
				}
				$node->{java_Name} = $self->_get_Name($node);
				$node->{java_holder} = $type->{java_holder};
				$node->{java_init} = $type->{java_init};
				$node->{java_read} = $type->{java_read};
				$node->{java_write} = $type->{java_write};
				$node->{java_type_code} = $type->{java_type_code};
			} else {
				$type->visitName($self);
				if (	   $type->isa('BasicType')
						or $type->isa('StringType')
						or $type->isa('WideStringType')
						or $type->isa('FixedPtType') ) {
					$node->{java_package} = $type->{java_package};
					$node->{java_name} = $type->{java_name};
					$node->{java_Name} = $type->{java_Name};
					$node->{java_holder} = $type->{java_holder};
					$node->{java_init} = $type->{java_init};
					$node->{java_read} = $type->{java_read};
					$node->{java_write} = $type->{java_write};
					$node->{java_type_code} = $type->{java_type_code};
				} else {
					$node->{java_package} = $self->_get_pkg($node);
					$node->{java_name} = $self->_get_name($node);
					$node->{java_Name} = $self->_get_Name($node);
					$node->{java_holder} = $node->{java_Name} . "Holder";
					$node->{java_init} = "null";
					$node->{java_read} = $node->{java_Name} . "Helper.read (is)";
					$node->{java_write} = $node->{java_Name} . "Helper.write (os, ";
					$node->{java_type_code} = $node->{java_Name} . "Helper.type ()";
				}
			}
		}
	}
}

#
#	3.11.1	Basic Types
#
#	See	1.4		Mapping for Basic Data Types
#

sub visitNameBasicType {
	my $self = shift;
	my($node) = @_;
	if      ($node->isa('FloatingPtType')) {
		if      ($node->{value} eq 'float') {
			$node->{java_package} = "";
			$node->{java_name} = "float";
			$node->{java_Name} = "float";
			$node->{java_holder} = "org.omg.CORBA.FloatHolder";
			$node->{java_init} = "(float)0";
			$node->{java_read} = "is.read_float ()";
			$node->{java_write} = "os.write_float (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_float)";
		} elsif ($node->{value} eq 'double') {
			$node->{java_package} = "";
			$node->{java_name} = "double";
			$node->{java_Name} = "double";
			$node->{java_holder} = "org.omg.CORBA.DoubleHolder";
			$node->{java_init} = "(double)0";
			$node->{java_read} = "is.read_double ()";
			$node->{java_write} = "os.write_double (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_double)";
		} elsif ($node->{value} eq 'long double') {
			warn __PACKAGE__," 'long double' not available at this time for Java.\n";
			$node->{java_package} = "";
			$node->{java_name} = "double";
			$node->{java_Name} = "double";
			$node->{java_holder} = "org.omg.CORBA.DoubleHolder";
			$node->{java_init} = "(double)0";
			$node->{java_read} = "is.read_double ()";
			$node->{java_write} = "os.write_double (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_double)";
		} else {
			warn __PACKAGE__,"::visitNameBasicType (FloatingType) $node->{value}.\n";
		}
	} elsif ($node->isa('IntegerType')) {
		if      ($node->{value} eq 'short') {
			$node->{java_package} = "";
			$node->{java_name} = "short";
			$node->{java_Name} = "short";
			$node->{java_holder} = "org.omg.CORBA.ShortHolder";
			$node->{java_init} = "(short)0";
			$node->{java_read} = "is.read_short ()";
			$node->{java_write} = "os.write_short (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_short)";
		} elsif ($node->{value} eq 'unsigned short') {
			$node->{java_package} = "";
			$node->{java_name} = "short";
			$node->{java_Name} = "short";
			$node->{java_holder} = "org.omg.CORBA.ShortHolder";
			$node->{java_init} = "(short)0";
			$node->{java_read} = "is.read_ushort ()";
			$node->{java_write} = "os.write_ushort (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_ushort)";
		} elsif ($node->{value} eq 'long') {
			$node->{java_package} = "";
			$node->{java_name} = "int";
			$node->{java_Name} = "int";
			$node->{java_holder} = "org.omg.CORBA.IntHolder";
			$node->{java_init} = "0";
			$node->{java_read} = "is.read_long ()";
			$node->{java_write} = "os.write_long (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_long)";
		} elsif ($node->{value} eq 'unsigned long') {
			$node->{java_package} = "";
			$node->{java_name} = "int";
			$node->{java_Name} = "int";
			$node->{java_holder} = "org.omg.CORBA.IntHolder";
			$node->{java_init} = "0";
			$node->{java_read} = "is.read_ulong ()";
			$node->{java_write} = "os.write_ulong (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_ulong)";
		} elsif ($node->{value} eq 'long long') {
			$node->{java_package} = "";
			$node->{java_name} = "long";
			$node->{java_Name} = "long";
			$node->{java_holder} = "org.omg.CORBA.LongHolder";
			$node->{java_init} = "(long)0";
			$node->{java_read} = "is.read_longlong ()";
			$node->{java_write} = "os.write_longlong (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_longlong)";
		} elsif ($node->{value} eq 'unsigned long long') {
			$node->{java_package} = "";
			$node->{java_name} = "long";
			$node->{java_Name} = "long";
			$node->{java_holder} = "org.omg.CORBA.LongHolder";
			$node->{java_init} = "(long)0";
			$node->{java_read} = "is.read_ulonglong ()";
			$node->{java_write} = "os.write_ulonglong (";
			$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_ulonglong)";
		} else {
			warn __PACKAGE__,"::visitNameBasicType (IntegerType) $node->{value}.\n";
		}
	} elsif ($node->isa('CharType')) {
		$node->{java_package} = "";
		$node->{java_name} = "char";
		$node->{java_Name} = "char";
		$node->{java_holder} = "org.omg.CORBA.CharHolder";
		$node->{java_init} = "'\\0'";
		$node->{java_read} = "is.read_char ()";
		$node->{java_write} = "os.write_char (";
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_char)";
	} elsif ($node->isa('WideCharType')) {
		$node->{java_package} = "";
		$node->{java_name} = "char";
		$node->{java_Name} = "char";
		$node->{java_holder} = "org.omg.CORBA.CharHolder";
		$node->{java_init} = "'\\0'";
		$node->{java_read} = "is.read_wchar ()";
		$node->{java_write} = "os.write_wchar (";
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_wchar)";
	} elsif ($node->isa('BooleanType')) {
		$node->{java_package} = "";
		$node->{java_name} = "boolean";
		$node->{java_Name} = "boolean";
		$node->{java_holder} = "org.omg.CORBA.BooleanHolder";
		$node->{java_init} = "false";
		$node->{java_read} = "is.read_boolean ()";
		$node->{java_write} = "os.write_boolean (";
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_boolean)";
	} elsif ($node->isa('OctetType')) {
		$node->{java_package} = "";
		$node->{java_name} = "byte";
		$node->{java_Name} = "byte";
		$node->{java_holder} = "org.omg.CORBA.ByteHolder";
		$node->{java_init} = "(byte)0";
		$node->{java_read} = "is.read_octet ()";
		$node->{java_write} = "os.write_octet (";
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_octet)";
	} elsif ($node->isa('AnyType')) {
		$node->{java_package} = "org.omg.CORBA";
		$node->{java_name} = "Any";
		$node->{java_Name} = "org.omg.CORBA.Any";
		$node->{java_holder} = "org.omg.CORBA.AnyHolder";
		$node->{java_init} = "null";
		$node->{java_read} = "is.read_any ()";
		$node->{java_write} = "os.write_any (";
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_any)";
	} elsif ($node->isa('ObjectType')) {
		$node->{java_package} = "org.omg.CORBA";
		$node->{java_name} = "Object";
		$node->{java_Name} = "org.omg.CORBA.Object";
		$node->{java_holder} = "org.omg.CORBA.ObjectHolder";
		$node->{java_init} = "null";
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_objref)";
	} elsif ($node->isa('ValueBaseType')) {
		$node->{java_package} = "java.io";
		$node->{java_name} = "Serializable";
		$node->{java_Name} = "java.io.Serializable";
#		$node->{java_holder} = "org.omg.CORBA.ValueBaseHolder";
		$node->{java_init} = "null";
#		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_objref)";
	} else {
		warn __PACKAGE__,"::visitNameBasicType INTERNAL ERROR (",ref $node,").\n";
	}
}

#
#	3.11.2	Constructed Types
#
#	3.11.2.1	Structures
#

sub visitNameStructType {
	my $self = shift;
	my($node) = @_;
	return if (exists $node->{java_package});
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_Name} = $self->_get_Name($node);
	$node->{java_holder} = $node->{java_Name} . "Holder";
	$node->{java_init} = "null";
	$node->{java_read} = $node->{java_Name} . "Helper.read (is)";
	$node->{java_write} = $node->{java_Name} . "Helper.write (os, ";
	$node->{java_type_code} = $node->{java_Name} . "Helper.type ()";
	foreach (@{$node->{list_value}}) {
		$self->_get_defn($_)->visitName($self);		# single or array
	}
}

sub visitNameArray {
	my $self = shift;
	my($node) = @_;
	my $type = $self->_get_defn($node->{type});
	my $array = '';
	foreach (@{$node->{array_size}}) {
		$array .= "[]";
	}
	while ($type->isa('SequenceType')) {
		$array .= "[]";
		$type = $self->_get_defn($type->{type});
	}
	$type->visitName($self);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_init} = $type->{java_Name} . " " . $node->{java_name} . $array . " = null";		# struct
	$node->{java__init} = $type->{java_Name} . " _" . $node->{java_name} . $array . " = null";		# union
	$node->{java_type} = $type->{java_Name} . $array;
}

sub visitNameSingle {
	my $self = shift;
	my($node) = @_;
	my $type = $self->_get_defn($node->{type});
	$node->{java_name} = $self->_get_name($node);
	while ($type->isa('TypeDeclarator') and !exists($type->{array_size})) {
		$type = $self->_get_defn($type->{type});
	}
	if ($type->isa('SequenceType') or exists ($type->{array_size})) {
		my $array = '';
		while ($type->isa('SequenceType')) {
			$array .= "[]";
			$type = $self->_get_defn($type->{type});
		}
		$type->visitName($self);
		$node->{java_init} = $type->{java_Name} . " " . $node->{java_name} . $array . " = null";		# struct
		$node->{java__init} = $type->{java_Name} . " _" . $node->{java_name} . $array . " = null";		# union
		$node->{java_type} = $type->{java_Name} . $array;
	} else {
		$type->visitName($self);
		$node->{java_init} = $type->{java_Name} . " " . $node->{java_name} . " = " . $type->{java_init};
		$node->{java__init} = $type->{java_Name} . " _" . $node->{java_name} . " = " . $type->{java_init};
		$node->{java_type} = $type->{java_Name};
	}
}

#	3.11.2.2	Discriminated Unions
#

sub visitNameUnionType {
	my $self = shift;
	my($node) = @_;
	return if (exists $node->{java_package});
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_Name} = $self->_get_Name($node);
	$node->{java_holder} = $node->{java_Name} . "Holder";
	$node->{java_init} = "null";
	$node->{java_read} = $node->{java_Name} . "Helper.read (is)";
	$node->{java_write} = $node->{java_Name} . "Helper.write (os, ";
	$node->{java_type_code} = $node->{java_Name} . "Helper.type ()";
	$self->_get_defn($node->{type})->visitName($self);
	foreach (@{$node->{list_expr}}) {
		$_->visitName($self);			# case
	}
}

sub visitNameCase {
	my $self = shift;
	my($node) = @_;
	foreach (@{$node->{list_label}}) {
		$_->visitName($self);			# default or expression
	}
	$node->{element}->visitName($self);
}

sub visitNameDefault {
	# empty
}

sub visitNameElement {
	my $self = shift;
	my($node) = @_;
	$self->_get_defn($node->{value})->visitName($self);		# single or array
}

#	3.11.2.4	Enumerations
#

sub visitNameEnumType {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_Name} = $self->_get_Name($node);
	$node->{java_holder} = $node->{java_Name} . "Holder";
	$node->{java_init} = "null";
	$node->{java_read} = $node->{java_Name} . "Helper.read (is)";
	$node->{java_write} = $node->{java_Name} . "Helper.write (os, ";
	$node->{java_type_code} = $node->{java_Name} . "Helper.type ()";
	foreach (@{$node->{list_expr}}) {
		$_->visitName($self);			# enum
	}
}

sub visitNameEnum {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_Name} = $self->_get_Name($node);
}

#
#	3.11.3	Template Types
#
#	See	1.11	Mapping for Sequence Types
#

sub visitNameSequenceType {
	my $self = shift;
	my($node, $name) = @_;
	return if (exists $node->{java_package});
	$node->{java_package} = $self->_get_pkg($node);
	my $type = $self->_get_defn($node->{type});
	$type->visitName($self);
	unless (defined $name) {
		$name = '_seq_' . $type->{java_name};
		if (exists $node->{max}) {
			$name .= '_' . $node->{max}->{value};
			$name =~ s/\+//g;
		}
	}
	$node->{java_name} = $name;
	$node->{java_Name} = $self->_get_Name($node);
	$node->{java_holder} = $node->{java_Name} . "Holder";
	$node->{java_init} = "null";
	$node->{java_read} = $node->{java_Name} . "Helper.read (is)";
	$node->{java_write} = $node->{java_Name} . "Helper.write (os, ";
#	if (exists $node->{max}) {
#		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().create_sequence_tc (" . $node->{max}->{value} . ", " . $type->{java_Name} . "Helper.type ())";
#	} else {
#		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().create_sequence_tc (0, " . $type->{java_Name} . "Helper.type ())";
#	}
}

#
#	See	1.12	Mapping for Strings
#

sub visitNameStringType {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = "java.lang";
	$node->{java_name} = "String";
	$node->{java_Name} = "java.lang.String";
	$node->{java_holder} = "org.omg.CORBA.StringHolder";
	$node->{java_init} = "null";
	$node->{java_read} = "is.read_string ()";
	$node->{java_write} = "os.write_string (";
	if (exists $node->{max}) {
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().create_string_tc (" . $node->{max}->{value} . ")";
	} else {
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().create_string_tc (0)";
	}
}

#
#	See	1.13	Mapping for Wide Strings
#

sub visitNameWideStringType {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = "java.lang";
	$node->{java_name} = "String";
	$node->{java_Name} = "java.lang.String";
	$node->{java_holder} = "org.omg.CORBA.StringHolder";
	$node->{java_init} = "null";
	$node->{java_read} = "is.read_string ()";
	$node->{java_write} = "os.write_string (";
	if (exists $node->{max}) {
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().create_wstring_tc (" . $node->{max}->{value} . ")";
	} else {
		$node->{java_type_code} = "org.omg.CORBA.ORB.init ().create_wstring_tc (0)";
	}
}

#
#	See	1.14	Mapping for Fixed
#

sub visitNameFixedPtType {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = "java.math";
	$node->{java_name} = "BigDecimal";
	$node->{java_Name} = "java.math.BigDecimal";
	$node->{java_holder} = "org.omg.CORBA.FixedHolder";
	$node->{java_init} = "null";
	$node->{java_read} = "is.read_fixed ()";		# deprecated by CORBA 2.4
	$node->{java_write} = "os.write_fixed (";		# deprecated by CORBA 2.4
	$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_fixed)";
}

sub visitNameFixedPtConstType {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = "java.math";
	$node->{java_name} = "BigDecimal";
	$node->{java_Name} = "java.math.BigDecimal";
	$node->{java_holder} = "org.omg.CORBA.FixedHolder";
	$node->{java_init} = "null";
	$node->{java_read} = "is.read_fixed ()";		# deprecated by CORBA 2.4
	$node->{java_write} = "os.write_fixed (";		# deprecated by CORBA 2.4
	$node->{java_type_code} = "org.omg.CORBA.ORB.init ().get_primitive_tc (org.omg.CORBA.TCKind.tk_fixed)";
}

#
#	3.12	Exception Declaration
#

sub visitNameException {
	my $self = shift;
	my($node) = @_;
	return if (exists $node->{java_package});
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$node->{java_Name} = $self->_get_Name($node);
	$node->{java_holder} = $node->{java_Name} . "Holder";
	$node->{java_init} = "null";
	$node->{java_read} = $node->{java_Name} . "Helper.read (is)";
	$node->{java_write} = $node->{java_Name} . "Helper.write (os, ";
	$node->{java_type_code} = $node->{java_Name} . "Helper.type ()";
	foreach (@{$node->{list_value}}) {
		$self->_get_defn($_)->visitName($self);		# single or array
	}
}

#
#	3.13	Operation Declaration
#
#	See	1.4		Inheritance and Operation Names
#

sub visitNameOperation {
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	$self->_get_defn($node->{type})->visitName($self);
	foreach (@{$node->{list_param}}) {
		$_->visitName($self);			# parameter
	}
}

sub visitNameParameter {
	my $self = shift;
	my($node) = @_;
	$node->{java_name} = $self->_get_name($node);
	$self->_get_defn($node->{type})->visitName($self);
}

sub visitNameVoidType {
	my $self = shift;
	my($node) = @_;
	$node->{java_Name} = "void";
}

#
#	3.14	Attribute Declaration
#

sub visitNameAttribute {
	my $self = shift;
	my($node) = @_;
	$node->{_get}->visitName($self);
	$node->{_set}->visitName($self) if (exists $node->{_set});
}

#
#	3.15	Repository Identity Related Declarations
#

sub visitNameTypeId {
	# empty
}

sub visitNameTypePrefix {
	# empty
}

#
#	3.16	Event Declaration
#

#
#	3.17	Component Declaration
#

sub visitNameProvides {
	# JAVA mapping is aligned with CORBA 2.4
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
}

sub visitNameUses {
	# JAVA mapping is aligned with CORBA 2.4
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
}

sub visitNamePublishes {
	# JAVA mapping is aligned with CORBA 2.4
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
}

sub visitNameEmits {
	# JAVA mapping is aligned with CORBA 2.4
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
}

sub visitNameConsumes {
	# JAVA mapping is aligned with CORBA 2.4
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
}

#
#	3.18	Home Declaration
#

sub visitNameFactory {
	# JAVA mapping is aligned with CORBA 2.4
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	foreach (@{$node->{list_param}}) {
		$_->visitName($self);			# parameter
	}
}

sub visitNameFinder {
	# JAVA mapping is aligned with CORBA 2.4
	my $self = shift;
	my($node) = @_;
	$node->{java_package} = $self->_get_pkg($node);
	$node->{java_name} = $self->_get_name($node);
	foreach (@{$node->{list_param}}) {
		$_->visitName($self);			# parameter
	}
}

1;

