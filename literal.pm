use strict;
use UNIVERSAL;

#
#			Interface Definition Language (OMG IDL CORBA v3.0)
#
#			IDL to Java Language Mapping Specification, Version 1.2 August 2002
#

package JavaLiteralVisitor;

# needs $node->{java_name} (JavaNameVisitor) for Enum
# builds $node->{java_literal}

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);
	my ($parser) = @_;
	$self->{key} = 'java_literal';
	$self->{symbtab} = $parser->YYData->{symbtab};
	return $self;
}

sub _get_defn {
	my $self = shift;
	my ($defn) = @_;
	if (ref $defn) {
		return $defn;
	} else {
		return $self->{symbtab}->Lookup($defn);
	}
}

sub visitNameType {
	my $self = shift;
	my ($type) = @_;

	if (ref $type) {
		$type->visitName($self);
	} else {
		$self->{symbtab}->Lookup($type)->visitName($self);
	}
}

#
#	3.5		OMG IDL Specification
#

sub visitNameSpecification {
	my $self = shift;
	my ($node) = @_;
	foreach (@{$node->{list_export}}) {
		$self->{symbtab}->Lookup($_)->visitName($self);
	}
}

#
#	3.7		Module Declaration
#

sub visitNameModules {
	my $self = shift;
	my ($node) = @_;
	foreach (@{$node->{list_export}}) {
		$self->{symbtab}->Lookup($_)->visitName($self);
	}
}

#
#	3.8		Interface Declaration
#

sub visitNameBaseInterface {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{$self->{key}});
	$node->{$self->{key}} = 1;
	foreach (@{$node->{list_export}}) {
		$self->{symbtab}->Lookup($_)->visitName($self);
	}
}

#
#	3.9		Value Declaration
#

sub visitNameStateMember {
	my $self = shift;
	my ($node) = @_;
	$self->visitNameType($node->{type});	# type_spec
	if (exists $node->{array_size}) {
		foreach (@{$node->{array_size}}) {
			my $str = $_->{value};
			$str =~ s/^\+//;
			$_->{$self->{key}} = $str;
		}
	}
}

sub visitNameInitializer {
	my $self = shift;
	my ($node) = @_;
	foreach (@{$node->{list_param}}) {
		$_->visitName($self);				# parameter
	}
}

#
#	3.10	Constant Declaration
#

sub visitNameConstant {
	my $self = shift;
	my ($node) = @_;
	my $defn;
	my $pkg = $node->{full};
	$pkg =~ s/::[0-9A-Z_a-z]+$//;
	$defn = $self->{symbtab}->Lookup($pkg) if ($pkg);
	if ( defined $defn and $defn->isa('BaseInterface') ) {
		$node->{$self->{key}} = $node->{java_Name};
	} else {
		$node->{$self->{key}} = $node->{java_Name} . '.value';
	}
	$node->{value}->visitName($self);		# expression
	$self->_get_defn($node->{type})->visitName($self);
}

sub _Eval {
	my $self = shift;
	my ($list_expr, $type) = @_;
	my $elt = pop @{$list_expr};
	unless (ref $elt) {
		$elt = $self->{symbtab}->Lookup($elt);
	}
	if (      $elt->isa('BinaryOp') ) {
		my $right = $self->_Eval($list_expr, $type);
		my $left = $self->_Eval($list_expr, $type);
		return "(" . $left . " " . $elt->{op} . " " . $right . ")";
	} elsif ( $elt->isa('UnaryOp') ) {
		my $right = $self->_Eval($list_expr, $type);
		return $elt->{op} . $right;
	} elsif ( $elt->isa('Constant') ) {
		return $elt->{java_Name};
	} elsif ( $elt->isa('Enum') ) {
		return $elt->{java_Name};
	} elsif ( $elt->isa('Literal') ) {
		$elt->visitName($self, $type);
		return $elt->{$self->{key}};
	} else {
		warn __PACKAGE__,"::_Eval: INTERNAL ERROR ",ref $elt,".\n";
		return undef;
	}
}

sub visitNameExpression {
	my $self = shift;
	my ($node) = @_;
	my @list_expr = @{$node->{list_expr}};		# create a copy
	$node->{$self->{key}} = $self->_Eval(\@list_expr, $node->{type});
}

sub visitNameIntegerLiteral {
	my $self = shift;
	my ($node, $type) = @_;
	my $str = $node->{value};
	$str =~ s/^\+//;
	my $cast = "";
	if      ($type->{value} eq 'short') {
		$cast = "(short)";
	} elsif ($type->{value} eq 'unsigned short') {
		$cast = "(short)";
	} elsif ($type->{value} eq 'long') {
		# empty
	} elsif ($type->{value} eq 'unsigned long') {
		# empty
	} elsif ($type->{value} eq 'long long') {
		$cast = "(long)";
	} elsif ($type->{value} eq 'unsigned long long') {
		$cast = "(long)";
	} elsif ($type->{value} eq 'octet') {
		$cast = "(byte)";
	} else {
		warn __PACKAGE__,"::visitNameIntegerLiteral $type->{value}.\n";
	}
	$node->{$self->{key}} = $cast . $str;
}

sub visitNameStringLiteral {
	my $self = shift;
	my ($node) = @_;
	my @list = unpack "C*",$node->{value};
	my $str = "\"";
	foreach (@list) {
		if      ($_ == 10) {
			$str .= "\\n";
		} elsif ($_ == 13) {
			$str .= "\\r";
		} elsif ($_ == 34) {
			$str .= "\\\"";
		} elsif ($_ < 32 or $_ >= 128) {
			$str .= sprintf "\\u%04x",$_;
		} else {
			$str .= chr $_;
		}
	}
	$str .= "\"";
	$node->{$self->{key}} = $str;
}

sub visitNameWideStringLiteral {
	shift->visitNameStringLiteral(@_);
}

sub visitNameCharacterLiteral {
	my $self = shift;
	my ($node) = @_;
	my @list = unpack "C",$node->{value};
	my $c = $list[0];
	my $str = "'";
	if      ($c == 10) {
		$str .= "\\n";
	} elsif ($c == 13) {
		$str .= "\\r";
	} elsif ($c == 39) {
		$str .= "\\'";
	} elsif ($c < 32 or $c >= 128) {
		$str .= sprintf "\\u%04x",$c;
	} else {
		$str .= chr $c;
	}
	$str .= "'";
	$node->{$self->{key}} = $str;
}

sub visitNameWideCharacterLiteral {
	shift->visitNameCharacterLiteral(@_);
}

sub visitNameFixedPtLiteral {
	my $self = shift;
	my ($node) = @_;
	my $str = "\"";
	$str .= $node->{value};
	$str .= "\"";
	$node->{$self->{key}} = $str;
}

sub visitNameFloatingPtLiteral {
	my $self = shift;
	my ($node, $type) = @_;
	my $str = $node->{value};
	if (      $type->{value} eq 'float' ) {
		$str .= 'f';
	} elsif ( $type->{value} eq 'double' ) {
		$str .= 'd';
	} elsif ( $type->{value} eq 'long double' ) {
		$str .= 'd';
	}
	$node->{$self->{key}} = $str;
}

sub visitNameBooleanLiteral {
	my $self = shift;
	my ($node) = @_;
	if ($node->{value} eq 'TRUE') {
		$node->{$self->{key}} = 'true';
	} else {
		$node->{$self->{key}} = 'false';
	}
}

#
#	3.11	Type Declaration
#

sub visitNameTypeDeclarator {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{modifier});	# native IDL2.2
	$self->visitNameType($node->{type});
	if (exists $node->{array_size}) {
		foreach (@{$node->{array_size}}) {
			my $str = $_->{value};
			$str =~ s/^\+//;
			$_->{$self->{key}} = $str;
		}
	}
}

#
#	3.11.1	Basic Types
#

sub visitNameBasicType {
	# empty
}

sub visitNameAnyType {
	# empty
}

#
#	3.11.2	Constructed Types
#
#	3.11.2.1	Structures
#

sub visitNameStructType {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{$self->{key}});
	$node->{$self->{key}} = 1;
	foreach (@{$node->{list_value}}) {
		$self->visitNameType($_);			# single or array
	}
}

sub visitNameArray {
	my $self = shift;
	my ($node) = @_;
	$self->visitNameType($node->{type});
	foreach (@{$node->{array_size}}) {
		my $str = $_->{value};
		$str =~ s/^\+//;
		$_->{$self->{key}} = $str;
	}
}

sub visitNameSingle {
	my $self = shift;
	my ($node) = @_;
	$self->visitNameType($node->{type});
}

#	3.11.2.2	Discriminated Unions
#

sub visitNameUnionType {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{$self->{key}});
	$node->{$self->{key}} = 1;
	my $type = $self->_get_defn($node->{type});
	$self->visitNameType($type);
	foreach (@{$node->{list_expr}}) {
		$_->visitName($self, $type);		# case
	}
}

sub visitNameCase {
	my $self = shift;
	my ($node, $type) = @_;
	foreach (@{$node->{list_label}}) {
		if      ($type->isa('EnumType') and $_->isa('Expression')) {
			$_->{$self->{key}} = $type->{java_Name} . '._' . $_->{value}->{java_name};
		} else {
			$_->visitName($self);			# default or expression
		}
	}
	$node->{element}->visitName($self);		# array or single
}

sub visitNameDefault {
	# empty
}

sub visitNameElement {
	my $self = shift;
	my ($node) = @_;
	$self->visitNameType($node->{value});	# single or array
}

#	3.11.2.4	Enumerations
#

sub visitNameEnumType {
	my $self = shift;
	my ($node) = @_;
	foreach (@{$node->{list_expr}}) {
		$_->visitName($self);				# enum
	}
}

sub visitNameEnum {
	my $self = shift;
	my ($node) = @_;
	my $type = $self->_get_defn($node->{type});
	$node->{$self->{key}} = $type->{java_Name} . '.' . $node->{java_name};
}

#
#	3.11.3	Template Types
#

sub visitNameSequenceType {
	my $self = shift;
	my ($node) = @_;
	$self->visitNameType($node->{type});
	$node->{max}->visitName($self) if (exists $node->{max});
}

sub visitNameStringType {
	my $self = shift;
	my ($node) = @_;
	$node->{max}->visitName($self) if (exists $node->{max});
}

sub visitNameWideStringType {
	my $self = shift;
	my ($node) = @_;
	$node->{max}->visitName($self) if (exists $node->{max});
}

sub visitNameFixedPtType {
	my $self = shift;
	my ($node) = @_;
	$node->{d}->visitName($self);
	$node->{s}->visitName($self);
}

sub visitNameFixedPtConstType {
	# empty
}

#
#	3.12	Exception Declaration
#

sub visitNameException {
	my $self = shift;
	my ($node) = @_;
	foreach (@{$node->{list_value}}) {
		$self->visitNameType($_);			# single or array
	}
}

#
#	3.13	Operation Declaration
#

sub visitNameOperation {
	my $self = shift;
	my ($node) = @_;
	$self->visitNameType($node->{type});	# param_type_spec or void
	foreach (@{$node->{list_param}}) {
		$_->visitName($self);				# parameter
	}
}

sub visitNameParameter {
	my $self = shift;
	my ($node) = @_;
	$self->visitNameType($node->{type});	# param_type_spec
}

sub visitNameVoidType {
	# empty
}

#
#	3.14	Attribute Declaration
#

sub visitNameAttribute {
	my $self = shift;
	my ($node) = @_;
	$self->visitNameType($node->{type});	# param_type_spec
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
	# empty
}

sub visitNameUses {
	# empty
}

sub visitNamePublishes {
	# empty
}

sub visitNameEmits {
	# empty
}

sub visitNameConsumes {
	# empty
}

#
#	3.18	Home Declaration
#

sub visitNameFactory {
	my $self = shift;
	my ($node) = @_;
	foreach (@{$node->{list_param}}) {
		$_->visitName($self);				# parameter
	}
}

sub visitNameFinder {
	my $self = shift;
	my ($node) = @_;
	foreach (@{$node->{list_param}}) {
		$_->visitName($self);				# parameter
	}
}

1;

