#!/usr/bin/raku
use v6;

use lib '../lib';
use ComRate::Extractor;
use ComRate::Extractor::Workbook;
use ComRate::Extractor::Essentials;

my $ess = ComRate::Extractor::Essentials.new;

sub MAIN ( Str :$filename ){

	my $workbook = ComRate::Extractor::Workbook.new(
		:$ess,
		:$filename
	);
	
    my $xr = ComRate::Extractor.new(
		:$ess,
        :$workbook
    );
    
    $xr.extract;
    
    # ... Dump $xr->results as JSON
    
}