use v6;
use Data::Dump;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Workbook;
use ComRate::Extractor::Identifier_Sheet;

unit class ComRate::Extractor;

has ComRate::Extractor::Essentials $.ess is required;
has ComRate::Extractor::Workbook $.workbook is required;

method extract {

	self.workbook.load;
	self.workbook.get_sheets;

    my @options = ['balance','cashflow','income'];

	my $sheet_idr = ComRate::Extractor::Identifier_Sheet.new(
		ess => self.ess,
		to_identify => self.workbook.sheets,
        options => @options
	);

    $sheet_idr.identify;

	my $results = {};

	for $sheet_idr.identified.kv -> $opt, $sh_i {

        say "$opt -> $sh_i";
        
	}

}
