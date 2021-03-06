package SBEAMS::Microarray;

###############################################################################
# Program     : SBEAMS::Microarray
# Author      : Eric Deutsch <edeutsch@systemsbiology.org>
# $Id$
#
# Description : Perl Module to handle all SBEAMS-Microarray specific items.
#
###############################################################################


use strict;
use vars qw($VERSION @ISA $sbeams);
use CGI::Carp qw( croak);

use SBEAMS::Connection::Settings;
use SBEAMS::Connection::Log;
use SBEAMS::Microarray::DBInterface;
use SBEAMS::Microarray::HTMLPrinter;
use SBEAMS::Microarray::TableInfo;
use SBEAMS::Microarray::Tables;
use SBEAMS::Microarray::Settings;
use SBEAMS::Microarray::Utilities;

@ISA = qw(SBEAMS::Microarray::DBInterface
          SBEAMS::Microarray::HTMLPrinter
          SBEAMS::Microarray::TableInfo
          SBEAMS::Microarray::Utilities
          SBEAMS::Microarray::Settings);


###############################################################################
# Global Variables
###############################################################################
$VERSION = '0.02';
my $log = SBEAMS::Connection::Log->new();


###############################################################################
# Constructor
###############################################################################
sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;
    return($self);
}


###############################################################################
# Receive the main SBEAMS object
###############################################################################
sub setSBEAMS {
    my $self = shift;
    $sbeams = shift;
    return($sbeams);
}


###############################################################################
# Provide the main SBEAMS object
###############################################################################
sub getSBEAMS {
    my $self = shift;
    return($sbeams);
}

sub getProjectData {
  my $self = shift;
  my %args = @_;
  my %project_data;

  unless ( scalar(@{$args{projects}}) ) {
    $log->warn( 'No project list provided to getProjectData' );
    return ( \%project_data);
  }
 
  my $projects = join ',', @{$args{projects}};

  # SQL to determine which projects have data.
  my $sql =<<"  END_SQL";

  SELECT project_id, SUM(two_color) AS two_color, SUM(affy) AS affy FROM
    ( 
    SELECT project_id, COUNT(*) AS two_color, 0 AS affy
    FROM $TBMA_ARRAY
    WHERE record_status != 'D'
    GROUP BY project_id
    UNION ALL
    SELECT project_id, 0 AS two_color, COUNT(*) AS affy 
    FROM $TBMA_AFFY_ARRAY_SAMPLE
    WHERE record_status != 'D'
    GROUP BY project_id
    ) AS temp_table
  WHERE project_id IN ( $projects )
  GROUP BY project_id
  END_SQL

  my $cgi_dir = $CGI_BASE_DIR . '/Microarray/';
  my @rows = $self->getSBEAMS()->selectSeveralColumns( $sql );
  foreach my $row ( @rows ) {
    my $title = '';
    $title .= "$row->[1] two-color arrays" if $row->[1];
    $title .= ', ' if ( $row->[1] && $row->[2] );
    $title .= "$row->[2] Affymetrix arrays" if $row->[2];

    $project_data{$row->[0]} =<<"    END_LINK";
    <A HREF=${cgi_dir}main.cgi?set_current_project_id=$row->[0]>
    <DIV id=Microarray_button TITLE='$title'>Microarray</DIV></A>
    END_LINK
  }
  return ( \%project_data );
}



###############################################################################

1;

__END__
###############################################################################
###############################################################################
###############################################################################
