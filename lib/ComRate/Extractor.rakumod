use v6;
use Data::Dump;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Workbook;
use ComRate::Extractor::Worksheet;
use ComRate::Extractor::Identifier_Structure;
use ComRate::Extractor::Identifier_Sheet;
use Data::Dump;

#constant Worksheet = ComRate::Extractor::Worksheet;


unit class ComRate::Extractor;

has ComRate::Extractor::Essentials $.ess is required;
has ComRate::Extractor::Workbook $.workbook is required;

method extract {

	self.workbook.load;
	self.workbook.get_sheets;

    my @options = ['balance','cashflow','income'];

    my Worksheet @to_identify = self.workbook.sheets;

	my $sheet_idr = ComRate::Extractor::Identifier_Sheet.new(
		:$!ess, :@to_identify, :@options
	);

    my $structure_idr = ComRate::Extractor::Identifier_Structure.new(:$.ess);

    $sheet_idr.identify;

	my $results = {};

	for $sheet_idr.identified.kv -> $opt, $sh_i {
        $structure_idr.worksheet = self.workbook.sheets[ $sh_i ];
        $structure_idr.identify;
        say "structure: " ~ Dump( $structure_idr.structure );

        say "$opt -> $sh_i";

	}

}
