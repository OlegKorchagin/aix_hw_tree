#!/usr/bin/perl

use strict;
use Data::Dumper;

################################################################################
#my %devices;
#my $tree = {
#	'/'	=> {},
#};
#my %known = (
#	'/' => $tree->{'/'},
#);
#open my $DEV, "lsdev -F name,parent |";
#	while ( my $line = <$DEV> ){
#		chomp $line;
#		my ($dev,$parent) = split(',', $line );
#		$devices {  $dev } = $parent;
#	};
#close $DEV;
#printf "%s\n", Dumper(\%devices);
#
#my $maxdepth=3;
#my $i=0;

#while ( ( scalar keys %devices ) and $i <= $maxdepth ) {
#	for my $dev ( keys %devices ) {
#		my $parent = $devices{$dev};
#		if ( ! $parent ) {
#			$parent = '/'
#		};
#
#		if ( exists ( $known{$parent} ) ) {
#			my $children = {};
#			$known{$parent}->{$dev}=$children;
#			$known{$dev} = $children;
#			
#			delete( $devices{$dev} );
#		};
#	};
#	$i++;
#};
#for my $dev ( keys %known) {
#	delete ($known{$dev});
#};
#printf "%s\n", Dumper($tree);

################################################################################
# а теперь через рекурсию

my @devices;
open my $DEV, "lsdev -F name,parent |";
	while ( my $line = <$DEV> ){
		chomp $line;
		my ($dev,$parent) = split(',', $line );
		push @devices, [ $dev, $parent ];
	};
close $DEV;

my %descr;
open my $DEV, "lsdev |";
while ( my $line = <$DEV> ) {
	chomp $line;
	if ( $line =~ m/^(\S+)\s+(\S.*)$/ ) {
		my ( $dev, $description ) = ( $1, $2 );
		$descr{$dev} = $description;
	}
}
close $DEV;

#printf "%s\n", Dumper(\@devices);
sub print_subtree($$){
	my $curr=shift;
	my $level = shift;
	my $width=4;
	my $descr_start=50;

	#if ( $level >=3 ) {
	#	return;
	#};

	for my $pair ( 
		#sort { $a->[0] cmp $b->[0] }
			@devices
	){
		my $child = $pair->[0];
		my $parent = $pair->[1];

		if ( "$parent" eq "$curr" ) {
			my $description = $descr{$child};
			my $descr_space=$descr_start - $width * $level - 3 - length($child);
			if ( $descr_space < 1 ) { $descr_space = 1};

			printf( "%s%s%s%s\n",
				sprintf ("%-${width}s", '|') x $level,
				"|--",
				$child,
				sprintf ( "%s%s", ' ' x $descr_space, $description ),
			);
			print_subtree($child, $level+1);
		}
	}
	#printf "%s\n", sprintf ("%-${width}s", '|') x $level;
}

print_subtree('',0);
