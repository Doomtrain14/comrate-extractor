use v6;
use ComRate::Extractor::Essentials;
use Spreadsheet::ParseExcel::Worksheet:from<Perl5>;
use Data::Dump;

unit class ComRate::Extractor::Worksheet;

has ComRate::Extractor::Essentials $.ess is required;

has $.xlsx;
has @.sections;

method name {
    return $.xlsx.get_name;
}

method cells {
    my $x = 0;

    my $row = 10;
    my $col = 3;

    my ( $max_row, $min_row ) = $.xlsx.row_range;
    my ( $max_col, $min_col ) = $.xlsx.col_range;

    say "row_range: $min_row:$max_row";
    say "col_range: $min_col:$max_col";
    #for $.xlsx<MinRow> .. $.xlsx<MaxRow> -> $row {
    #    for $.xlsx<MinCol> .. $.xlsx<MaxCol> -> $col {
            my $cell = $.xlsx.get_cell( $row, $col );
            say "($row,$col): ", $cell ?? $cell<Formula> !! '';
    #    }
    #}

}
