#!/usr/local/bin/perl -w

#$Id:  $

use DBI;
use Test::More tests => 12;
use Test::Harness;
use strict;
use FindBin qw ( $Bin );
use lib( "$Bin/../.." );

# Globals
my $sbeams;
my $atlas;
my $pepselector;

use_ok( 'SBEAMS::Connection' );
use_ok( 'SBEAMS::PeptideAtlas' );
use_ok( 'SBEAMS::PeptideAtlas::BestPeptideSelector' );
ok( get_sbeams(), 'Instantiate sbeams object' );
ok( get_atlas(), 'Instantiate peptide atlas object' );
ok( authenticate(), 'Authenticate login' );
like( get_file( touch => 1, file => '' ), qr/\/tmp\/interact.xml/, 'Fetch filename without preferred' );

like( get_file( touch => 1, file => 'interact-combined.iproph.pep.xml', preferred => ['interact-combined.iproph.pep.xml'] ), 
              qr/\/tmp\/interact-combined.iproph.pep.xml/,
             'Fetch filename with preferred' );

ok( get_best_pep_selector(), 'Instantiate selector' );
ok( test_bad_peptide(), 'Check bad peptide scoring' );
ok( test_good_peptide(), 'Check good peptide scoring' );
ok( test_bad_override_peptide(), 'Check bad with override peptide scoring' );

sub test_bad_peptide {
# A very bad peptide, should hit the following penalties!
#  Code    Penal   Description
#  M       .3      Exclude/Avoid M
#  nQ      .1      Exclude N-terminal Q
#  C       .7      Avoid C (dirty peptides don't come alkylated but can be)
#  W       .2      Exclude W
#  NG      .3      Avoid dipeptide NG
#  DP      .3      Avoid dipeptide DP
#  QG      .3      Avoid dipeptide QG
#  nxxG    .3      Avoid nxxG
#  nGPG    .1      Exclude nxyG where x or y is P or G
#  D       .9      Slightly penalize D or S in general?
#  S       .9      Slightly penalize D or S in general?
#
#  changed...
#
#    my %scores =  (  M => .3,
#                  nQ => .1,
#                  nE => .4,
#                  Xc => .5,
#                   C => .3,
#                   W => .1,
#                   P => .3,
#                  NG => .5,
#                  DP => .5,
#                  QG => .5,
#                  DG => .5,
#                nxxG => .3,
#                nGPG => .1,
#                   D => 1.0,
#                   S => 1.0 );
#
  my $peptide = 'QPGMCWNGDPQGDSR';
	my @peptides = ( [$peptide, 100000000] );
	my $results = $pepselector->pabst_evaluate_peptides( peptides => \@peptides, score_idx => 1 );
	for my $res ( @{$results} ) {
		if ( int($res->[4]) == 101 ) {
      return 1;
    } else {
      return 0;
    }
	}
}

sub test_bad_override_peptide {
  my %scores = ( M => 1,
                nQ => 1,
                C => 1,
                W => 1,
                P => 1,
                NG => 1,
                DP => 1,
                QG => 1,
                nxxG => 1,
                nGPG => 1,
                D => 1,
                S => 1 );

  my $peptide = 'QPGMCWNGDPQGDSR';
	my @peptides = ( [$peptide, 1000] );
	my $results = $pepselector->pabst_evaluate_peptides( peptides => \@peptides, score_idx => 1, pen_defs => \%scores );
	for my $res ( @{$results} ) {
		if ( int($res->[4]) == 1000 ) {
      return 1;
    } else {
      return 0;
    }
	}
}

sub test_good_peptide {
  my $peptide = 'AGNTLLDIIK';
	my @peptides = ( [$peptide, 1000] );
	my $results = $pepselector->pabst_evaluate_peptides( peptides => \@peptides, score_idx => 1 );
	for my $res ( @{$results} ) {
		if ( int($res->[4]) == 1000 ) {
      return 1;
    } else {
      return 0;
    }
	}
	return 1;
}

sub get_file {
	my %args = @_;
	$args{file} ||= 'interact.xml';
	$args{preferred} ||= [];
	if ( $args{touch} ) {
		open( FIL, ">/tmp/$args{file}" ) || die( "unable to open file!" );
		close FIL;
	}

	my $result = $atlas->findPepXMLFile( search_path => '/tmp', preferred_names => $args{preferred} );
	if ( $args{touch} ) {
		system "rm /tmp/$args{file}";
	}
	return $result;
}


sub get_sbeams {
  $sbeams = new SBEAMS::Connection;
  return $sbeams;
}

sub get_atlas {
  $atlas = new SBEAMS::PeptideAtlas;
  return $atlas;
}

sub get_best_pep_selector {
	$pepselector = new SBEAMS::PeptideAtlas::BestPeptideSelector;
	return $pepselector;
}


sub authenticate {
  return $sbeams->Authenticate();
}


sub breakdown {
 # Put clean-up code here
}
END {
  breakdown();
} # End END