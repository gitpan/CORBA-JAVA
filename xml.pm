use strict;

#
#			Interface Definition Language (OMG IDL CORBA v3.0)
#

use CORBA::Java::class;

package CORBA::JAVA::XMLclassVisitor;

@CORBA::JAVA::XMLclassVisitor::ISA = qw(CORBA::JAVA::classVisitor);

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	bless($self, $class);
	my ($parser) = @_;
	$self->{srcname} = $parser->YYData->{srcname};
	$self->{srcname_size} = $parser->YYData->{srcname_size};
	$self->{srcname_mtime} = $parser->YYData->{srcname_mtime};
	$self->{symbtab} = $parser->YYData->{symbtab};
	$self->{done_hash} = {};
	$self->{num_key} = 'num_javaxml';
	$self->{toString} = 1;
	$self->{equals} = 1;
	$self->{xml_pkg} = "org.omg.CORBA.portable.XML";
	return $self;
}

#
#	3.8		Interface Declaration
#

sub _interface_helperXML {
	my ($self, $node) = @_;

	$self->open_stream($node, 'HelperXML.java');
	my $FH = $self->{out};
	print $FH "abstract public class ",$node->{java_helper},"HelperXML\n";
	print $FH "{\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	print $FH "  {\n";
	print $FH "    return read (\$is, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    // TODO\n";
	print $FH "    return null;\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value)\n";
	print $FH "  {\n";
	print $FH "    write (\$os, value, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    \$os.write_Object ((org.omg.CORBA.Object) value, tag);\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "}\n";
	close $FH;
}

#
#	3.9		Value Declaration
#
#	3.9.1	Regular Value Type
#

sub _value_helperXML {
	my ($self, $node) = @_;

	$self->open_stream($node, 'HelperXML.java');
	my $FH = $self->{out};
	print $FH "abstract public class ",$node->{java_helper},"HelperXML\n";
	print $FH "{\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	print $FH "  {\n";
	print $FH "    return read (\$is, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    // TODO (Pb with instanciation)\n";
	print $FH "    return null;\n";
#	print $FH "    ",$node->{java_Name}," value = new ",$node->{java_Name}," ();\n";
#	print $FH "    \$is.read_open_tag (tag);\n";
	my $idx = 0;
#	foreach (@{$node->{list_member}}) {		# StateMember
#		my $member = $self->_get_defn($_);
#		$self->_member_helperXML_read($member, $node, \$idx);
#	}
#	print $FH "    \$is.read_close_tag (tag);\n";
#	print $FH "    return value;\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value)\n";
	print $FH "  {\n";
	print $FH "    write (\$os, value, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    \$os.write_open_tag (tag);\n";
	$idx = 0;
	foreach (@{$node->{list_member}}) {		# StateMember
		my $member = $self->_get_defn($_);
		$self->_member_helperXML_write($member, $node, \$idx);
	}
	print $FH "    \$os.write_close_tag (tag);\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "}\n";
	close $FH;
}

#	3.9.2	Boxed Value Type
#

sub _boxed_helperXML {
	my ($self, $node, $type, $array, $type2, $array_max) = @_;

	$self->open_stream($node, 'HelperXML.java');
	my $FH = $self->{out};
#	print $FH "public final class ",$node->{java_helper},"HelperXML implements org.omg.CORBA.portable.BoxedValueHelperXML\n";
	print $FH "public final class ",$node->{java_helper},"HelperXML\n";
	print $FH "{\n";
	print $FH "\n";
	if (exists $node->{java_primitive}) {
		print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	} else {
		print $FH "  public static ",$type->{java_Name},@{$array}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	}
	print $FH "  {\n";
	print $FH "    // TODO (PB instanciation)\n";
	print $FH "    return null;\n";
	print $FH "  }\n";
	print $FH "\n";
	if (exists $node->{java_primitive}) {
		print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value)\n";
	} else {
		print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$type->{java_Name},@{$array}," value)\n";
	}
	print $FH "  {\n";
	print $FH "    write (\$os, value, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	if (exists $node->{java_primitive}) {
		print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value, java.lang.String tag)\n";
	} else {
		print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$type->{java_Name},@{$array}," value, java.lang.String tag)\n";
	}
	print $FH "  {\n";
	print $FH "    \$os.write_open_tag (tag);\n";
	if (exists $node->{java_primitive}) {
		print $FH "    ",$type->{java_write_xml},"value.value, \"value\");\n";
	} else {
		my @tab = ("    ");
		my $i = 0;
		my $idx = '';
		my $tag;
		my $nb_item = scalar(@{$array});
		if (exists $node->{array_size}) {
			foreach (@{$node->{array_size}}) {
				$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"value\"";
				print $FH @tab,"\$os.write_open_tag (",$tag,");\n";
				print $FH @tab,"if (value",$idx,".length != (",$_->{java_literal},"))\n";
				print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
				print $FH @tab,"for (int _i",$i," = 0; _i",$i," < (",$_->{java_literal},"); _i",$i,"++)\n";
				print $FH @tab,"{\n";
				$idx .= "[_i" . $i . "]";
				$i ++;
				push @tab, "  ";
			}
		}
		foreach (@{$array_max}) {
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"value\"";
			print $FH @tab,"\$os.write_open_tag (",$tag,");\n";
			if (defined $_) {
				print $FH @tab,"if (value",$idx,".length > (",$_->{java_literal},"))\n";
				print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
			}
			print $FH @tab,"for (int _i",$i," = 0; _i",$i," < value",$idx,".length; _i",$i,"++)\n";
			print $FH @tab,"{\n";
			$idx .= "[_i" . $i . "]";
			$i ++;
			push @tab, "  ";
		}
		if (($type2->isa('StringType') or $type2->isa('WideStringType')) and exists $type2->{max}) {
			print $FH @tab,"if (value",$idx,".length () > (",$type2->{max}->{java_literal},"))\n";
			print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
		}
		$tag = $i ? "\"item\"" : "\"value\"";
		print $FH @tab,$type2->{java_write_xml},"value",$idx,", ",$tag,");\n";
		foreach (@{$array_max}) {
			pop @tab;
			$i --;
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"value\"";
			print $FH @tab,"}\n";
			print $FH @tab,"\$os.write_close_tag (",$tag,");\n";
		}
		if (exists $node->{array_size}) {
			foreach (@{$node->{array_size}}) {
				pop @tab;
				$i --;
				$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"value\"";
				print $FH @tab,"}\n";
				print $FH @tab,"\$os.write_close_tag (",$tag,");\n";
			}
		}
	}
	print $FH "    \$os.write_close_tag (tag);\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "}\n";
	close $FH;
}

#
#	3.11	Type Declaration
#

sub _typedeclarator_helperXML {
	my ($self, $node, $type, $array, $type2, $array_max) = @_;

	$self->open_stream($node, 'HelperXML.java');
	my $FH = $self->{out};
	print $FH "abstract public class ",$node->{java_helper},"HelperXML\n";
	print $FH "{\n";
	print $FH "\n";
	print $FH "  public static ",$type->{java_Name},@{$array}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	print $FH "  {\n";
	print $FH "    return read (\$is, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static ",$type->{java_Name},@{$array}," read (",$self->{xml_pkg},"InputStream \$is, java.lang.String tag)\n";
	print $FH "  {\n";
	if (scalar(@{$array})) {
		print $FH "    ",$type->{java_Name}," value",@{$array}," = null;\n";
	} else {
		print $FH "    ",$type->{java_Name}," value = ",$type->{java_init},";\n";
	}
	my @tab = ("    ");
	my $i = 0;
	my $idx = '';
	my @array1= @{$array};
	my $tag;
	my $nb_item = scalar(@{$array});
	if (exists $node->{array_size}) {
		foreach (@{$node->{array_size}}) {
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "tag";
			pop @array1;
			print $FH @tab,"\$is.read_open_tag (",$tag,");\n";
			print $FH @tab,"value",$idx," = new ",$type->{java_Name}," [",$_->{java_literal},"]",@array1,";\n";
			print $FH @tab,"for (int _o",$i," = 0; _o",$i," < (",$_->{java_literal},"); _o",$i,"++)\n";
			print $FH @tab,"{\n";
			$idx .= "[_o" . $i . "]";
			$i ++;
			push @tab, "  ";
		}
	}
	foreach (@{$array_max}) {
		$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "tag";
		pop @array1;
		print $FH @tab,"\$is.read_open_tag (",$tag,");\n";
		print $FH @tab,"value",$idx," = new ",$type->{java_Name}," [0]",@array1,";\n";
		print $FH @tab,"for (int _o",$i," = 0; true; _o",$i,"++)\n";
		print $FH @tab,"{\n";
		print $FH @tab,"  try {\n";
		$idx .= "[_o" . $i . "]";
		$i ++;
		push @tab, "    ";
	}
	$tag = $i ? "\"item\"" : "tag";
	print $FH @tab,"value",$idx," = ",$type2->{java_read_xml},$tag,");\n";
	if (($type2->isa('StringType') or $type2->isa('WideStringType')) and exists $type2->{max}) {
		print $FH @tab,"if (value",$idx,".length () > (",$type2->{max}->{java_literal},"))\n";
		print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
	}
	foreach (@{$array_max}) {
		pop @tab;
		$i --;
		$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "tag";
		$idx =~ s/\[[^\]]+\]$//;
		print $FH @tab,"  }\n";
		print $FH @tab,"  catch (Exception \$ex) {\n";
		print $FH @tab,"    break;\n";
		print $FH @tab,"  }\n";
		print $FH @tab,"}\n";
		if (defined $_) {
			print $FH @tab,"if (value",$idx,".length > (",$_->{java_literal},"))\n";
			print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
		}
		print $FH @tab,"\$is.read_close_tag (",$tag,");\n";
	}
	if (exists $node->{array_size}) {
		foreach (@{$node->{array_size}}) {
			pop @tab;
			$i --;
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "tag";
			print $FH @tab,"}\n";
			print $FH @tab,"\$is.read_close_tag (",$tag,");\n";
		}
	}
	print $FH "    return value;\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$type->{java_Name},@{$array}," value)\n";
	print $FH "  {\n";
	print $FH "    write (\$os, value, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$type->{java_Name},@{$array}," value, java.lang.String tag)\n";
	print $FH "  {\n";
	@tab = ("    ");
	$i = 0;
	$idx = '';
	if (exists $node->{array_size}) {
		foreach (@{$node->{array_size}}) {
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "tag";
			print $FH @tab,"\$os.write_open_tag (",$tag,");\n";
			print $FH @tab,"if (value",$idx,".length != (",$_->{java_literal},"))\n";
			print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
			print $FH @tab,"for (int _i",$i," = 0; _i",$i," < (",$_->{java_literal},"); _i",$i,"++)\n";
			print $FH @tab,"{\n";
			$idx .= "[_i" . $i . "]";
			$i ++;
			push @tab, "  ";
		}
	}
	foreach (@{$array_max}) {
		$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "tag";
		print $FH @tab,"\$os.write_open_tag (",$tag,");\n";
		if (defined $_) {
			print $FH @tab,"if (value",$idx,".length > (",$_->{java_literal},"))\n";
			print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
		}
		print $FH @tab,"for (int _i",$i," = 0; _i",$i," < value",$idx,".length; _i",$i,"++)\n";
		print $FH @tab,"{\n";
		$idx .= "[_i" . $i . "]";
		$i ++;
		push @tab, "  ";
	}
	if (($type2->isa('StringType') or $type2->isa('WideStringType')) and exists $type2->{max}) {
		print $FH @tab,"if (value",$idx,".length () > (",$type2->{max}->{java_literal},"))\n";
		print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
	}
	$tag = $i ? "\"item\"" : "tag";
	print $FH @tab,$type2->{java_write_xml},"value",$idx,", ",$tag,");\n";
	foreach (@{$array_max}) {
		pop @tab;
		$i --;
		$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "tag";
		print $FH @tab,"}\n";
		print $FH @tab,"\$os.write_close_tag (",$tag,");\n";
	}
	if (exists $node->{array_size}) {
		foreach (@{$node->{array_size}}) {
			pop @tab;
			$i --;
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "tag";
			print $FH @tab,"}\n";
			print $FH @tab,"\$os.write_close_tag (",$tag,");\n";
		}
	}
	print $FH "  }\n";
	print $FH "\n";
	print $FH "}\n";
	close $FH;
}

#
#	3.11.2	Constructed Types
#
#	3.11.2.1	Structures
#

sub _struct_helperXML {
	my ($self, $node) = @_;

	$self->open_stream($node, 'HelperXML.java');
	my $FH = $self->{out};
	print $FH "abstract public class ",$node->{java_name},"HelperXML\n";
	print $FH "{\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	print $FH "  {\n";
	print $FH "    return read (\$is, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    ",$node->{java_Name}," value = new ",$node->{java_Name}," ();\n";
	print $FH "    \$is.read_open_tag (tag);\n";
	my $idx = 0;
	foreach (@{$node->{list_member}}) {
		my $member = $self->_get_defn($_);
		$self->_member_helperXML_read($member, $node, \$idx);
	}
	print $FH "    \$is.read_close_tag (tag);\n";
	print $FH "    return value;\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value)\n";
	print $FH "  {\n";
	print $FH "    write (\$os, value, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    \$os.write_open_tag (tag);\n";
	$idx = 0;
	foreach (@{$node->{list_member}}) {
		my $member = $self->_get_defn($_);
		$self->_member_helperXML_write($member, $node, \$idx);
	}
	print $FH "    \$os.write_close_tag (tag);\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "}\n";
	close $FH;
}

sub _member_helperXML_read {
	my $self = shift;
	my ($member, $parent, $r_idx) = @_;

	my $FH = $self->{out};
	my $label = "";
#	unless ($member->isa('StateMember')) {
		if ($parent->isa('UnionType')) {
			$label = "_";
		} else {	# StructType or ExceptionType
			$label = "value.";
		}
#	}
	my $type = $self->_get_defn($member->{type});
	my $name = $member->{java_name};
	my @tab = ("    ");
	push @tab, "    " if ($parent->isa('UnionType'));
	my $idx = '';
	my $i = 0;
	my $tag;
	my @array1 = ();
	if (exists $member->{array_size}) {
		foreach (@{$member->{array_size}}) {
			push @array1, "[]";
		}
	}
	my @array_max = ();
	while ($type->isa('SequenceType')) {
		if (exists $type->{max}) {
			push @array_max, $type->{max};
		} else {
			push @array_max, undef;
		}
		push @array1, "[]";
		$type = $self->_get_defn($type->{type});
	}
	my $nb_item = scalar(@array_max);
	$nb_item += scalar(@{$member->{array_size}}) if (exists $member->{array_size});
	if ($parent->isa('UnionType')) {
		print $FH @tab,"  ",$member->{java_type}," _",$member->{java_name}," = ",$member->{java_init},";\n";
	}
	if (exists $member->{array_size}) {
		foreach (@{$member->{array_size}}) {
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"" . $member->{xsd_name} . "\"";
			pop @array1;
			print $FH @tab,"\$is.read_open_tag (",$tag,");\n";
			if ($parent->isa('UnionType')) {
				print $FH @tab,"_",$name,$idx," = new ",$type->{java_Name}," [",$_->{java_literal},"]",@array1,";\n";
			} else {	# StructType or ExceptionType
				print $FH @tab,"value.",$name,$idx," = new ",$type->{java_Name}," [",$_->{java_literal},"]",@array1,";\n";
			}
			print $FH @tab,"for (int _o",$$r_idx," = 0; _o",$$r_idx," < (",$_->{java_literal},"); _o",$$r_idx,"++)\n";
			print $FH @tab,"{\n";
			$idx .= "[_o" . $$r_idx . "]";
			$$r_idx ++;
			$i ++;
			push @tab, "  ";
		}
	}
	foreach (@array_max) {
		$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"" . $member->{xsd_name} . "\"";
		pop @array1;
		print $FH @tab,"\$is.read_open_tag (",$tag,");\n";
		if ($parent->isa('UnionType')) {
			print $FH @tab,"_",$name,$idx," = new ",$type->{java_Name}," [0]",@array1,";\n";
		} else {	# StructType or ExceptionType
			print $FH @tab,"value.",$name,$idx," = new ",$type->{java_Name}," [0]",@array1,";\n";
		}
		print $FH @tab,"for (int _o",$$r_idx," = 0; true; _o",$$r_idx,"++)\n";
		print $FH @tab,"{\n";
		print $FH @tab,"  try {\n";
		$idx .= "[_o" . $$r_idx . "]";
		$$r_idx ++;
		$i ++;
		push @tab, "    ";
	}
	$tag = $i ? "\"item\"" : "\"" . $member->{xsd_name} . "\"";
	if ($parent->isa('UnionType')) {
		print $FH @tab,"_",$name,$idx," = ",$type->{java_read_xml},$tag,");\n";
	} else {	# StructType or ExceptionType
		print $FH @tab,"value.",$name,$idx," = ",$type->{java_read_xml},$tag,");\n";
	}
	if (($type->isa('StringType') or $type->isa('WideStringType')) and exists $type->{max}) {
		print $FH @tab,"if (",$label,$name,$idx,".length () > (",$type->{max}->{java_literal},"))\n";
		print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
	}
	foreach (@array_max) {
		pop @tab;
		$i --;
		$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"" . $member->{xsd_name} . "\"";
		$idx =~ s/\[[^\]]+\]$//;
		print $FH @tab,"  }\n";
		print $FH @tab,"  catch (Exception \$ex) {\n";
		print $FH @tab,"    break;\n";
		print $FH @tab,"  }\n";
		print $FH @tab,"}\n";
		if (defined $_) {
			print $FH @tab,"if (value",$idx,".length > (",$_->{java_literal},"))\n";
			print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
		}
		print $FH @tab,"\$is.read_close_tag (",$tag,");\n";
	}
	if (exists $member->{array_size}) {
		foreach (@{$member->{array_size}}) {
			pop @tab;
			$i --;
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"" . $member->{xsd_name} . "\"";
			print $FH @tab,"}\n";
			print $FH @tab,"\$is.read_close_tag (",$tag,");\n";
			pop @tab;
		}
	}
}

sub _member_helperXML_write {
	my $self = shift;
	my ($member, $parent, $r_idx) = @_;

	my $FH = $self->{out};
#	my $label = ($member->isa('StateMember')) ? "" : "value.";
	my $label = "value.";
	my $type = $self->_get_defn($member->{type});
	my $name = $member->{java_name};
	my @tab = ("    ");
	push @tab, "    " if ($parent->isa('UnionType'));
	my $idx = '';
	my $i = 0;
	my $tag;
	my @array_max = ();
	while ($type->isa('SequenceType')) {
		if (exists $type->{max}) {
			push @array_max, $type->{max};
		} else {
			push @array_max, undef;
		}
		$type = $self->_get_defn($type->{type});
	}
	my $nb_item = scalar(@array_max);
	$nb_item += scalar(@{$member->{array_size}}) if (exists $member->{array_size});
	if (exists $member->{array_size}) {
		foreach (@{$member->{array_size}}) {
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"" . $member->{xsd_name} . "\"";
			print $FH @tab,"\$os.write_open_tag (",$tag,");\n";
			print $FH @tab,"if (value.",$name,$idx,".length != (",$_->{java_literal},"))\n";
			print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
			print $FH @tab,"for (int _i",$$r_idx," = 0; _i",$$r_idx," < (",$_->{java_literal},"); _i",$$r_idx,"++)\n";
			print $FH @tab,"{\n";
			$idx .= "[_i" . $$r_idx . "]";
			$$r_idx ++;
			$i ++;
			push @tab, "  ";
		}
	}
	foreach (@array_max) {
		$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"" . $member->{xsd_name} . "\"";
		print $FH @tab,"\$os.write_open_tag (",$tag,");\n";
		if (defined $_) {
			print $FH @tab,"if (value.",$name,$idx,".length > (",$_->{java_literal},"))\n";
			print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
		}
		print $FH @tab,"for (int _i",$$r_idx," = 0; _i",$$r_idx," < value.",$name,$idx,".length; _i",$$r_idx,"++)\n";
		print $FH @tab,"{\n";
		$idx .= "[_i" . $$r_idx . "]";
		$$r_idx ++;
		$i ++;
		push @tab, "  ";
	}
	if (($type->isa('StringType') or $type->isa('WideStringType')) and exists $type->{max}) {
		if ($parent->isa('UnionType')) {
			print $FH @tab,"if (",$label,$name,$idx," ().length () > (",$type->{max}->{java_literal},"))\n";
		} else {	# StructType or ExceptionType
			print $FH @tab,"if (",$label,$name,$idx,".length () > (",$type->{max}->{java_literal},"))\n";
		}
		print $FH @tab,"  throw new org.omg.CORBA.MARSHAL (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);\n";
	}
	$tag = $i ? "\"item\"" : "\"" . $member->{xsd_name} . "\"";
	if ($parent->isa('UnionType')) {
		print $FH @tab,$type->{java_write_xml},"value.",$name," ()",$idx,", ",$tag,");\n";
	} else {	# StructType or ExceptionType
		print $FH @tab,$type->{java_write_xml},"value.",$name,$idx,", ",$tag,");\n";
	}
	foreach (@array_max) {
		pop @tab;
		$i --;
		$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"" . $member->{xsd_name} . "\"";
		print $FH @tab,"}\n";
		print $FH @tab,"\$os.write_close_tag (",$tag,");\n";
	}
	if (exists $member->{array_size}) {
		foreach (@{$member->{array_size}}) {
			pop @tab;
			$i --;
			$tag = $i ? "\"item" . ($nb_item - $i) . "\"" : "\"" . $member->{xsd_name} . "\"";
			print $FH @tab,"}\n";
			print $FH @tab,"\$os.write_close_tag (",$tag,");\n";
		}
	}
}

#	3.11.2.2	Discriminated Unions
#

sub _union_helperXML {
	my ($self, $node, $dis) = @_;

	$self->open_stream($node, 'HelperXML.java');
	my $FH = $self->{out};
	print $FH "abstract public class ",$node->{java_name},"HelperXML\n";
	print $FH "{\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	print $FH "  {\n";
	print $FH "    return read (\$is, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    ",$node->{java_Name}," value = new ",$node->{java_Name}," ();\n";
	print $FH "    ",$dis->{java_Name}," _dis0 = ",$dis->{java_init},";\n";
	print $FH "    \$is.read_open_tag (tag);\n";
	print $FH "    _dis0 = ",$dis->{java_read_xml},"\"discriminator\");\n";
	if ($dis->isa('EnumType')) {
		print $FH "    switch (_dis0.value ())\n";
	} else {
		print $FH "    switch (_dis0)\n";
	}
	print $FH "    {\n";
	my $idx = 0;
	foreach my $case (@{$node->{list_expr}}) {
		foreach (@{$case->{list_label}}) {	# default or expression
			if ($_->isa('Default')) {
				print $FH "      default:\n";
			} else {
				print $FH "      case ",$_->{java_literal},":\n";
			}
		}
		my $elt = $case->{element};
		my $value = $self->_get_defn($elt->{value});
		$self->_member_helperXML_read($value, $node, \$idx);
		if (scalar(@{$case->{list_label}}) > 1) {
			if ($dis->isa('EnumType')) {
				print $FH "        value.",$value->{java_name}," (_dis0.value (), _",$value->{java_name},");\n";
			} else {
				print $FH "        value.",$value->{java_name}," (_dis0, _",$value->{java_name},");\n";
			}
		} else {
			print $FH "        value.",$value->{java_name}," (_",$value->{java_name},");\n";
		}
		print $FH "        break;\n";
	}
	if (exists $node->{need_default}) {
		print $FH "      default:\n";
		print $FH "        throw new org.omg.CORBA.BAD_OPERATION ();\n";
	}
	print $FH "    }\n";
	print $FH "    \$is.read_close_tag (tag);\n";
	print $FH "    return value;\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value)\n";
	print $FH "  {\n";
	print $FH "    write (\$os, value, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    \$os.write_open_tag (tag);\n";
	print $FH "    ",$dis->{java_write_xml},"value.discriminator (), \"discriminator\");\n";
	if ($dis->isa('EnumType')) {
		print $FH "    switch (value.discriminator ().value ())\n";
	} else {
		print $FH "    switch (value.discriminator ())\n";
	}
	print $FH "    {\n";
	$idx = 0;
	foreach my $case (@{$node->{list_expr}}) {
		foreach (@{$case->{list_label}}) {	# default or expression
			if ($_->isa('Default')) {
				print $FH "      default:\n";
			} else {
				print $FH "      case ",$_->{java_literal},":\n";
			}
		}
		my $elt = $case->{element};
		my $value = $self->_get_defn($elt->{value});
		$self->_member_helperXML_write($value, $node, \$idx);
		print $FH "        break;\n";
	}
	if (exists $node->{need_default}) {
		print $FH "      default:\n";
		print $FH "        throw new org.omg.CORBA.BAD_OPERATION ();\n";
	}
	print $FH "    }\n";
	print $FH "    \$os.write_close_tag (tag);\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "}\n";
	close $FH;
}

#	3.11.2.4	Enumerations
#

sub _enum_helperXML {
	my ($self, $node) = @_;

	$self->open_stream($node, 'HelperXML.java');
	my $FH = $self->{out};
	print $FH "abstract public class ",$node->{java_name},"HelperXML\n";
	print $FH "{\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	print $FH "  {\n";
	print $FH "    return read (\$is, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    \$is.read_open_tag (tag);\n";
	print $FH "    java.lang.String str = \$is.read_pcdata ();\n";
	print $FH "    \$is.read_close_tag (tag);\n";
	foreach (@{$node->{list_expr}}) {
		print $FH "    if (str.equals (\"",$_->{java_name},"\"))\n";
		print $FH "      return ",$_->{java_Name},";\n";
	}
	print $FH "    throw new org.omg.CORBA.BAD_PARAM ();\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value)\n";
	print $FH "  {\n";
	print $FH "    write (\$os, value, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    \$os.write_open_tag (tag);\n";
	print $FH "    \$os.write_pcdata (value.toString ());\n";
	print $FH "    \$os.write_close_tag (tag);\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "}\n";
	close $FH;
}

#
#	3.12	Exception Declaration
#

sub _exception_helperXML {
	my ($self, $node) = @_;

	$self->open_stream($node, 'HelperXML.java');
	my $FH = $self->{out};
	print $FH "abstract public class ",$node->{java_name},"HelperXML\n";
	print $FH "{\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is)\n";
	print $FH "  {\n";
	print $FH "    return read (\$is, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static ",$node->{java_Name}," read (",$self->{xml_pkg},"InputStream \$is, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    ",$node->{java_Name}," value = new ",$node->{java_Name}," ();\n";
	print $FH "    \$is.read_open_tag (tag);\n";
	my $idx = 0;
	foreach (@{$node->{list_member}}) {
		my $member = $self->_get_defn($_);
		$self->_member_helperXML_read($member, $node, \$idx);
	}
	print $FH "    \$is.read_close_tag (tag);\n";
	print $FH "    return value;\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value)\n";
	print $FH "  {\n";
	print $FH "    write (\$os, value, \"",$node->{xsd_name},"\");\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "  public static void write (",$self->{xml_pkg},"OutputStream \$os, ",$node->{java_Name}," value, java.lang.String tag)\n";
	print $FH "  {\n";
	print $FH "    \$os.write_open_tag (tag);\n";
	$idx = 0;
	foreach (@{$node->{list_member}}) {
		my $member = $self->_get_defn($_);
		$self->_member_helperXML_write($member, $node, \$idx);
	}
	print $FH "    \$os.write_close_tag (tag);\n";
	print $FH "  }\n";
	print $FH "\n";
	print $FH "}\n";
	close $FH;
}

###############################################################################

package CORBA::JAVA::nameXmlVisitor;

use CORBA::Java::name;

@CORBA::JAVA::nameXmlVisitor::ISA = qw(CORBA::JAVA::name2Visitor);

#
#	3.8		Interface Declaration
#

sub visitBaseInterface {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{java_read_xml});
	$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
	$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
	foreach (@{$node->{list_export}}) {
		$self->{symbtab}->Lookup($_)->visit($self);
	}
}

#
#	3.9		Value Declaration
#

sub visitBoxedValue {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{java_read_xml});

	my $type = $self->_get_defn($node->{type});
	$type->visit($self);
	if (exists $node->{java_primitive}) {
	} else {
		if ($type->isa('SequenceType')) {
			$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
			$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
		} else {
			$node->{java_read_xml} = $type->{java_read_xml};
			$node->{java_write_xml} = $type->{java_write_xml};
		}
	}
}

#
#	3.11	Type Declaration
#

sub visitTypeDeclarator {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{java_read_xml});
	my $type = $self->_get_defn($node->{type});
	$type->visit($self);
	if (exists $node->{array_size}) {
		$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
		$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
	} else {
		if ($type->isa('SequenceType')) {
			$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
			$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
		} else {
			if (	   $type->isa('BasicType')
					or $type->isa('StringType')
					or $type->isa('WideStringType')
					or $type->isa('FixedPtType') ) {
				$node->{java_read_xml} = $type->{java_read_xml};
				$node->{java_write_xml} = $type->{java_write_xml};
			} else {
				$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
				$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
			}
		}
	}
}

sub visitNativeType {
	# empty
}

#
#	3.11.1	Basic Types
#
#	See	1.4		Mapping for Basic Data Types
#

sub visitIntegerType {
	my $self = shift;
	my ($node) = @_;
	if      ($node->{value} eq 'short') {
		$node->{java_read_xml} = "\$is.read_short (";
		$node->{java_write_xml} = "\$os.write_short (";
	} elsif ($node->{value} eq 'unsigned short') {
		$node->{java_read_xml} = "\$is.read_ushort (";
		$node->{java_write_xml} = "\$os.write_ushort (";
	} elsif ($node->{value} eq 'long') {
		$node->{java_read_xml} = "\$is.read_long (";
		$node->{java_write_xml} = "\$os.write_long (";
	} elsif ($node->{value} eq 'unsigned long') {
		$node->{java_read_xml} = "\$is.read_ulong (";
		$node->{java_write_xml} = "\$os.write_ulong (";
	} elsif ($node->{value} eq 'long long') {
		$node->{java_read_xml} = "\$is.read_longlong (";
		$node->{java_write_xml} = "\$os.write_longlong (";
	} elsif ($node->{value} eq 'unsigned long long') {
		$node->{java_read_xml} = "\$is.read_ulonglong (";
		$node->{java_write_xml} = "\$os.write_ulonglong (";
	} else {
		warn __PACKAGE__,"::visitIntegerType $node->{value}.\n";
	}
}

sub visitFloatingPtType {
	my $self = shift;
	my ($node) = @_;
	if      ($node->{value} eq 'float') {
		$node->{java_read_xml} = "\$is.read_float (";
		$node->{java_write_xml} = "\$os.write_float (";
	} elsif ($node->{value} eq 'double') {
		$node->{java_read_xml} = "\$is.read_double (";
		$node->{java_write_xml} = "\$os.write_double (";
	} elsif ($node->{value} eq 'long double') {
		$node->{java_read_xml} = "\$is.read_double (";
		$node->{java_write_xml} = "\$os.write_double (";
	} else {
		warn __PACKAGE__,"::visitFloatingPtType $node->{value}.\n";
	}
}

sub visitCharType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = "\$is.read_char (";
	$node->{java_write_xml} = "\$os.write_char (";
}

sub visitWideCharType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = "\$is.read_wchar (";
	$node->{java_write_xml} = "\$os.write_wchar (";
}

sub visitBooleanType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = "\$is.read_boolean (";
	$node->{java_write_xml} = "\$os.write_boolean (";
}

sub visitOctetType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = "\$is.read_octet (";
	$node->{java_write_xml} = "\$os.write_octet (";
}

sub visitAnyType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = "\$is.read_any (";
	$node->{java_write_xml} = "\$os.write_any (";
}

sub visitObjectType {
	# empty ? TODO
}

sub visitValueBaseType {
	# empty ? TODO
}

#
#	3.11.2	Constructed Types
#
#	3.11.2.1	Structures
#

sub visitStructType {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{java_read_xml});
	$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
	$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
	foreach (@{$node->{list_member}}) {
		$self->_get_defn($_)->visit($self);
	}
}

sub visitMember {
	my $self = shift;
	my ($node) = @_;
	my $type = $self->_get_defn($node->{type});
	while ($type->isa('TypeDeclarator') and !exists($type->{array_size})) {
		$type = $self->_get_defn($type->{type});
	}
	if ($type->isa('SequenceType') or exists ($type->{array_size})) {
		while ($type->isa('SequenceType')) {
			$type = $self->_get_defn($type->{type});
		}
		$type->visit($self);
	} else {
		$type->visit($self);
	}
}

#	3.11.2.2	Discriminated Unions
#

sub visitUnionType {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{java_read_xml});
	$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
	$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
	$self->_get_defn($node->{type})->visit($self);
	foreach (@{$node->{list_expr}}) {
		$_->visit($self);			# case
	}
}

#	3.11.2.4	Enumerations
#

sub visitEnumType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
	$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
}

#
#	3.11.3	Template Types
#
#	See	1.11	Mapping for Sequence Types
#

sub visitSequenceType {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{java_read_xml});
	$self->_get_defn($node->{type})->visit($self);
	$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
	$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
}

#
#	See	1.12	Mapping for Strings
#

sub visitStringType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = "\$is.read_string (";
	$node->{java_write_xml} = "\$os.write_string (";
}

#
#	See	1.13	Mapping for Wide Strings
#

sub visitWideStringType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = "\$is.read_wstring (";
	$node->{java_write_xml} = "\$os.write_wstring (";
}

#
#	See	1.14	Mapping for Fixed
#

sub visitFixedPtType {
	my $self = shift;
	my ($node) = @_;
	$node->{java_read_xml} = "\$is.read_fixed (";
	$node->{java_write_xml} = "\$os.write_fixed (";
}

#
#	3.12	Exception Declaration
#

sub visitException {
	my $self = shift;
	my ($node) = @_;
	return if (exists $node->{java_read_xml});
	$node->{java_read_xml} = $node->{java_Helper} . "XML.read (\$is, ";
	$node->{java_write_xml} = $node->{java_Helper} . "XML.write (\$os, ";
	foreach (@{$node->{list_member}}) {
		$self->_get_defn($_)->visit($self);
	}
}

1;

