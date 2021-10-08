use v6;
use ComRate::Extractor::Essentials;
use Spreadsheet::ParseExcel::Worksheet:from<Perl5>;
use ComRate::Extractor::Worksheet::Cell;
use Data::Dump;

constant Cell = ComRate::Extractor::Worksheet::Cell;

unit class ComRate::Extractor::Worksheet;

has ComRate::Extractor::Essentials $.ess is required;

has $.xlsx;
has @.sections;
has Int $.max_row;
has Int $.max_col;
has Int $.min_row;
has Int $.min_col;
has Str $.name;

submethod BUILD ( :$xlsx, :$ess ) {
    die "xlsx is required" unless $xlsx;
    $!ess = $ess;

    if $xlsx {
        ( $!min_row, $!max_row ) = $xlsx.row_range;
        ( $!min_col, $!max_col ) = $xlsx.col_range;
        $!name = $xlsx.get_name;
        $!xlsx = $xlsx;
    }
}


#method name {
#    return $.xlsx.get_name;
#}

method cell( Int $row_num, Int $col_num --> Cell ) {

    die "row $row_num is greater than maximum ( $.max_row )" if $row_num > $.max_row;
    die "row $row_num is less than minimum ( $.min_row )" if $row_num < $.min_row;
    die "col $col_num is greater than maximum ( $.max_col )" if $col_num > $.max_col;
    die "row $col_num is less than minimum ( $.min_col )" if $col_num < $.min_col;

    if $.xlsx {
        my $cell = Cell.new(
            xlsx => $.xlsx.get_cell( $row_num, $col_num )
        );
        return $cell;
    }
}
