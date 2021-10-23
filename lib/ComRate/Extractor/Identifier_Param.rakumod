use v6;
use ComRate::Extractor::Identifier;
use ComRate::Extractor::Scorecard_Param;
use Data::Dump;
constant Identifier = ComRate::Extractor::Identifier;

unit class ComRate::Extractor::Identifier_Param is Identifier;

has Str $.sheet_name is rw; # 'balance', 'cashflow', 'income'
has %.structure is rw;
has @.exp_eqns is rw;

has $.line_count is rw = 0;
has %.cache is rw;

has @.key_fields is rw;
has %.collect is rw;

method index{

    # %.equations needs replacing with input from the yaml
    # we also will need to add in "eqn_type", which should
    # be "bound" only if all constituent equations are "bound"
    # but "unbound" if any one is "unbound"

    for |%.equations<income>.kv -> $param, @comps {
        self.expand_comps( $param, @comps );
    }

}



method expand_comps( $param, @comps ) {
    return if self.seen( $param, @comps );
    self.write_output( $param, @comps );

    for @comps.kv -> $i, $comp {
        my @comps_exp = @comps;

        if %.equations<income>{ $comp } {
            my @child_comps = |%.equations<income>{ $comp };
            my $recurse = False;
            for @child_comps -> $child_comp {
                if $param eq $child_comp { $recurse = True; last }
                if @comps_exp.grep: $child_comp { $recurse = True; last }
            }

            if not $recurse {
                @comps_exp.splice( $i, 1, |@child_comps );
                self.expand_comps( $param, @comps_exp );
            }
        }
    }
}


method seen( $param, @comps ){
    my $key = $param ~ '|' ~ @comps.sort.join('|');
    return True if %.cache{ $key };
    %.cache{ $key } = True;
    return False;
}

method write_output( $param, @comps ){

    # write to the database here

    $.line_count++;
    say "$.line_count: $param:\n";
    for @comps -> $comp {
        say "   $comp";
    }
    say "\n";
}



    # use database tables to create an "index" for fast look ups
    #
    # index only $.sheet_name if this is proided, otherwise index all sheets
    #
    # the following tables should be created/populated:
    #
    # sheet_param
    #    id
    #    sheet_name  ("balance", "cashflow", "income")
    #    name ("gross profit", "sales revenue" etc.)
    #
    # sheet_param_eqn ("eqn" = "equation" )
    #    id
    #    sheet_name
    #    param_id
    #    eqn_type
    #    num_comps (number of components, for fast lookups)
    #
    # sheet_param_eqn_comp ("comp" = "component")
    #    id
    #    eqn_id
    #    param__id

    # 1. the "index" method should create a fresh index from
    # the supplied param/relationship data - so tables should
    # be emptied at the start of the process
    #
    #
    # 2. insert the parameters to sheet_param

    # +--------+--------------+--------------------------
    # |  id    |  sheet_name  |  name                   |
    # +--------+--------------+-------------------------+
    # |   1    |  income      | gross profit            |
    # +--------+--------------+-------------------------+
    # |   2    |  income      | sales revenue           |
    # +--------+--------------+-------------------------+
    #
    # ... etc.
    #
    #
    # 3. Create relationship entries in sheet_param_eqn and
    # sheet_param_eqn_comp. This means creating an entry for
    # (a) the explicitly stated relationship, e.g.
    #
    # gross profit = sales revenue + cost of revenue
    #
    # but also (b) the relationships that are expansions of
    # the original. So for example we know
    #
    # sales revenue = operating revenue + non-operating revenue
    #
    # and thus
    #
    # gross profit = operating revenue + non-operating revenue + cost of revenue
    #
    # this will need to be done via some kind of recursive method
    # (How many table rows will this produce?)
    #



method identify {

    die "identify called but key_fields not provide" unless @.key_fields;
    die "identify called but structure not provided" unless %.structure;


    my $sc = ComRate::Extractor::Scorecard_Param.new: :$.ess;

    for @.key_fields.kv -> $i, %key_inf {

        my %best = (
            score => 0,
            param => '',
            param_inf => {}
        );

        for $.ess.conf<params>{ $.sheet_name }<params>.kv -> $param, %param_inf {

            $sc.type = $param;
            $sc.synonyms = |%param_inf<synonyms>;
            $sc.input = %key_inf<title>;
            my $score = $sc.evaluate;

            if $score > %best<score> {
                unless %.identified{ $param } and %.identified{ $param }<score> > $score {
                    %best = ( :$score, :$param, :%param_inf );
                }
            }
        }

        %.identified{ %best<param> } = %key_inf;
        %.identified{ %best<param> }<score> = %best<score>;
        %.collect{ %best<param> } = %key_inf if %best<param_inf><collect>;

    }

}
