use v6;
use lib '../lib';
use ComRate::Extractor::Identifier_Param;
use ComRate::Extractor::Essentials;

my $ess = ComRate::Extractor::Essentials.new;
my $idr = ComRate::Extractor::Identifier_Param.new( :$ess );

$idr.index;

say "*** DONE ***";
