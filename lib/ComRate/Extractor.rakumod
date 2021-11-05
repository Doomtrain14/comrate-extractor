use v6;
use Data::Dump;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Workbook;
use ComRate::Extractor::Worksheet;
use ComRate::Extractor::Identifier_Sheet;
use ComRate::Extractor::Identifier_Param;
use ComRate::Extractor::Identifier_Structure;




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

    my $structure_idr = ComRate::Extractor::Identifier_Structure.new: :$.ess;

    $sheet_idr.identify;

	my %results = ();

	for $sheet_idr.identified.kv -> $sheet_name, $sh_i {
        my $worksheet = self.workbook.sheets[ $sh_i ];
        $structure_idr.worksheet = $worksheet;
        $structure_idr.identify;
        #say "structure: " ~ Dump( $structure_idr.structure );
        my $param_idr = ComRate::Extractor::Identifier_Param.new:
            :$.ess,
            :$sheet_name,
            structure => $structure_idr.structure,
            key_fields => $structure_idr.key_fields;
        $param_idr.identify;
        #say "identify complete";

        my %sheet_results;

        #say "identified: " ~ Dump( $param_idr.identified );
        #say "collect: " ~ $param_idr.collect.gist;
        for $param_idr.collect.kv -> $param, %key_inf {
            my $row_num = %key_inf<position>[0];
            my $value = $worksheet.cell( $row_num, $structure_idr.data_col ).value;
            %sheet_results{ $param } = $value;
        }
        #say "identified: " ~ Dump( $param_idr.identified );
        %results{ $sheet_name } = %sheet_results;
	}



    return %results;

}
