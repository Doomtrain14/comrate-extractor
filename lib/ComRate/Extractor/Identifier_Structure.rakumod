use v6;
use ComRate::Extractor::Identifier;
use ComRate::Extractor::Worksheet;
constant Identifier = ComRate::Extractor::Identifier;
constant Worksheet = ComRate::Extractor::Worksheet;


unit class ComRate::Extractor::Identifier_Structure is Identifier;

has $.structure is rw;
has Worksheet $.worksheet is rw;
has @.row_types is rw;

method identify {

    for $.worksheet.min_row .. $.worksheet.max_row -> $row_num {
        my $row_type = self.identify_row( $row_num );
        say "ROW $row_num: $row_type" if $row_type ne 'empty';
        @.row_types.push: $row_type;
    }
}


method identify_row( Int $row_num ) {

    my $row_type = 'empty';

    for $.worksheet.min_col .. $.worksheet.max_col -> $col_num {
        my $cell = $.worksheet.cell( $row_num, $col_num );
        if $cell.type {
            $row_type = 'text' if $cell.type eq 'Text' and $cell.value and $row_type eq 'empty';
            $row_type = 'data' if $cell.type eq 'Numeric';
        }
        $row_type = 'total' if $cell.formula;

    }

    return $row_type;
}
