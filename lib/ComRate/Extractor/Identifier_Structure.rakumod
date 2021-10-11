use v6;
use ComRate::Extractor::Identifier;
use ComRate::Extractor::Worksheet;
constant Identifier = ComRate::Extractor::Identifier;
constant Worksheet = ComRate::Extractor::Worksheet;


unit class ComRate::Extractor::Identifier_Structure is Identifier;

has %.structure is rw;
has Worksheet $.worksheet is rw;
has @.row_types is rw;
has %.row_type_sets is rw;

has Int $.data_col is rw;
has Int $.key_col is rw;
has Int $.last_year is rw;
has Int $.header_row is rw;

has @!alphabet = 'A'..'Z';


method identify {
    $.identify_row_types;
    $.identify_header_row;
    $.identify_key_col;
    $.identify_data_col;
    $.identify_structure;
}


method identify_row_types {

    for $.worksheet.min_row .. $.worksheet.max_row -> $row_num {
        my $row_type = self.identify_row_type( $row_num );
        say "ROW $row_num: $row_type" if $row_type ne 'empty';
        @.row_types.push: $row_type;
    }

}



method identify_data_col {

    die "identify_data_col called but header_row not defined - did you forget to call identify_header_row ?" unless defined $.header_row;

    my Int $last_year = Nil;
    my Int $data_col = Nil;

    for $.worksheet.min_col .. $.worksheet.max_col -> $col_num {
        my $cell = $.worksheet.cell( $.header_row, $col_num );

        if $cell.value.Str ~~ / [^||\s] ([19||20] \d\d) [\s||$] / {
            my $this_year = $0.Int;
            if ! $last_year || $this_year > $last_year {
                $last_year = $this_year;
                $data_col = $col_num;
            }
        }
    }

    die "Could not identify data column" if ! $data_col;

    $.data_col = $data_col;
    $.last_year = $last_year;
    say "data col: $data_col";
    return $data_col;
}


method identify_header_row {
    my $col_header_row = 0;
    my $best_header_row_type = Nil;
    for @.row_types.kv -> $i, $row_type {
        next if $row_type eq 'empty';
        last if $row_type !~~ / [date||year||text] /;
        if $row_type eq 'year' {
            $best_header_row_type = 'year';
            $col_header_row = $i;
            next;
        }
        if $row_type eq 'date' && ( ! $best_header_row_type || $best_header_row_type ne 'year' ) {
            $best_header_row_type='date';
            $col_header_row = $i;
            next;
        }
        if $row_type eq 'text' && ( ! $best_header_row_type || $best_header_row_type eq 'text' ) {
            for $.worksheet.min_col .. $.worksheet.max_col -> $col_num {
                my $cell = $.worksheet.cell( $i, $col_num );
                if $cell.value.Str ~~ / [^||\s] [19||20] \d\d [\s||$] / {
                    $best_header_row_type='text';
                    $col_header_row = $i;
                }
            }
        }
    }

    die "Could not find a column header row" if ! $best_header_row_type;
    $.header_row = $col_header_row;
    return $col_header_row;
}


method identify_key_col{

    my $row_num = %.row_type_sets<data>[0];
    my $key_col = 0;

    for $.worksheet.min_col .. $.worksheet.max_col -> $col_num {
        my $cell = $.worksheet.cell( $row_num, $col_num );
        if $cell.type eq 'Text' and $cell.value {
            $key_col = $col_num;
            last;
        }
    }

    $.key_col = $key_col;
    return $key_col;
}



method identify_row_type( Int $row_num ) {

    my $row_type = 'empty';

    for $.worksheet.min_col .. $.worksheet.max_col -> $col_num {
        my $cell = $.worksheet.cell( $row_num, $col_num );
        if $cell.type {
            $row_type = 'text' if $cell.type eq 'Text' and $cell.value and $row_type eq 'empty';
            $row_type = 'date' if $cell.type eq 'Date';
            if $cell.type eq 'Numeric' {
                if $cell.value.Str ~~ / ^ [19||20] \d\d $ / {
                    $row_type = 'year'
                } else {
                    $row_type = 'data'
                }
            }
        }
        if $row_type ne 'formula' and $cell.formula {
            $row_type = 'formula';
            say "row $row_num formula " ~ $cell.formula;
        }

        %.row_type_sets{ $row_type } ||= [];
        %.row_type_sets{ $row_type }.push: $row_num;
    }

    return $row_type;
}


method cell_label_to_coord( Str $label ){
    my $col_label = $label ~~ / <[A..Z]>+ /;
    my $row_label = $label ~~ / <[0..9]>+ /;

    my $col_num = @!alphabet.grep: {$_ eq $col_label}, :k;
    my $row_num = $row_label.Int - 1;

    return ($row_num.Int, $col_num.Int );
}

method coord_to_cell_label( $row_num, $col_num ){
    my $col_label = @!alphabet[ $col_num ];
    my $row_label = $row_num + 1;

    return $col_label.Str ~ $row_label;
}



method identify_structure {

    my %structure;

    for |%.row_type_sets<formula> -> $i {

        my @component_cells;

        my $formula = $.worksheet.cell( $i, $.data_col ).formula;

        say "FORMULA: $formula";

        if $formula ~~ /SUM \( ( <-[\)]>+ ) \) / {
            my $contents = $0;
            say "contents: $contents";
            my @ranges = $contents.split: ',';
            for @ranges -> $range {
                my @delims = $range.split: ':';

                if @delims.elems == 1 {
                    my ($row_num,$col_num) = $.cell_label_to_coord( @delims[0] );
                    my $title = $.worksheet.cell( $row_num, $.key_col ).value.Str;

                    @component_cells.push: {
                        position => [ $row_num, $col_num ],
                        label => @delims[0],
                        title => $title;
                    };
                } else {
                    my ( $min_row, $min_col ) = $.cell_label_to_coord( @delims[0] );
                    my ( $max_row, $max_col ) = $.cell_label_to_coord( @delims[1] );

                    say "min_row: " ~ $min_row;
                    say "max_row: " ~ $max_row;
                    say "min_col: " ~ $min_col;
                    say "max_col: " ~ $max_col;

                    for $min_col..$max_col -> $col_num {
                        for $min_row..$max_row -> $row_num {
                            my $title = $.worksheet.cell( $row_num, $.key_col ).value.Str;

                            @component_cells.push: {
                                position => [ $row_num, $col_num ],
                                label => self.coord_to_cell_label( $row_num, $col_num ),
                                title => $title
                            };
                        }
                    }
                }
            }
        } elsif $formula ~~ / <[\+\-]> / {
            say "+- formula: $formula";

            my @labels = $formula.split: / <[\+\-]> /;
            for @labels -> $label {
                $label ~~ s/ ^ \s+ //;
                $label ~~ s/ \s+$ //;
                my  ( $row_num, $col_num ) = $.cell_label_to_coord( $label );
                my $title = $.worksheet.cell( $row_num, $.key_col ).value.Str;

                @component_cells.push: {
                    position => [ $row_num, $col_num ],
                    label => $label,
                    title => $title
                };
            }
        }

        my $label = $.coord_to_cell_label( $i, $.data_col );

        say "i: $i key_col: $.key_col";
        my $title = $.worksheet.cell( $i, $.key_col ).value.Str;
        %structure{ $label } = {
            title => $title,
            position => [ $i, $.key_col ],
            components => @component_cells
        };
    }

    %.structure = %structure;
}





#{
#    A23 => {
#        title => "Net Income",
#        position => [0,22],
#        components => ["A17","A18"]
#    }, ...

#    "Net Income" => [ "Pretax Income", "Tax Provision" ],
#    "Pretax Income" => ["Operating Income", "Non-Operating Income", "Other Income"],
