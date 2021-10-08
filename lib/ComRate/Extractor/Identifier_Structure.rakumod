use v6;
use ComRate::Extractor::Identifier;
use ComRate::Extractor::Worksheet;
constant Identifier = ComRate::Extractor::Identifier;
constant Worksheet = ComRate::Extractor::Worksheet;


unit class ComRate::Extractor::Identifier_Structure is Identifier;

has $.structure is rw;
has Worksheet $.worksheet is rw;

method identify {

    for $.worksheet.min_row .. $.worksheet.max_row -> $row_num {
        self.identify_row( $row_num );
    }
}


method identify_row( Int $row_num ) {

    my $type;

    for $.worksheet.min_col .. $.worksheet.max_col -> $col_num {
        my $value = $.worksheet.cell( $row_num, $col_num ).value;
        say "($row_num, $col_num): $value";

        # identify code goes here
        # evaluate type (maybe?)
    }

    return $type;
}
