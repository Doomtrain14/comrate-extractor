use v6;
use Data::Dump;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Workbook;
use ComRate::Extractor::Identifier_Structure;
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

    my $structure_idr = ComRate::Extractor::Identifier_Structure.new(
        ess => $.ess
    );


    $sheet_idr.identify;

	my $results = {};

	for $sheet_idr.identified.kv -> $opt, $sh_i {
        $structure_idr.to_identify = self.workbook.sheets[ $sh_i ].cells;
        $structure_idr.identify;

        say "$opt -> $sh_i";

	}

}
