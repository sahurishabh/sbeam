package SBEAMS::Biomarker;

###############################################################################
# Program     : SBEAMS::Biomarker
# Author      : Eric Deutsch <edeutsch@systemsbiology.org>
# $$
#
# Description : Perl Module to handle all SBEAMS - Biomarker specific items.
#
###############################################################################


use strict;
use vars qw($VERSION @ISA $sbeams);
use CGI::Carp qw(fatalsToBrowser croak);

use SBEAMS::Biomarker::DBInterface;
use SBEAMS::Biomarker::HTMLPrinter;
use SBEAMS::Biomarker::TableInfo;
use SBEAMS::Biomarker::Settings;

@ISA = qw(SBEAMS::Biomarker::DBInterface
          SBEAMS::Biomarker::HTMLPrinter
          SBEAMS::Biomarker::TableInfo
          SBEAMS::Biomarker::Settings);


###############################################################################
# Global Variables
###############################################################################
$VERSION = '0.02';


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


###############################################################################

1;

__END__
###############################################################################
###############################################################################
###############################################################################
