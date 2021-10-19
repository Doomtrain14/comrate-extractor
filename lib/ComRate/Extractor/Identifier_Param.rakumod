use v6;
use ComRate::Extractor::Identifier;
use Data::Dump;
constant Identifier = ComRate::Extractor::Identifier;

unit class ComRate::Extractor::Identifier_Param is Identifier;

# %.relationships and %.params below should be moved to conf/params.yaml

has %.equations = (
    income => {
        'gross profit' => [ 'sales revenue', 'cost of revenue' ],
        'sales revenue' => [ 'operating income', 'non-operating income' ],
        'operating expenses' => [ 'selling general and administrative expenses', 'research and development' ],
        'total expenses' => [ 'cost of revenue', 'operating expenses', 'non-operating expenses' ],
        'operating income' => [ 'gross profit', 'operating expenses' ],
        'EBIT' => [ 'operating income', 'net non-operating income (expense)', 'net other income (expense)' ],
        'EBITDA' => [ 'EBIT', 'depreciation and amortisation' ],
        'depreciation and amortisation' => [ 'depreciation', 'amortisation' ],
        'non-operating expenses' => [ 'interest expense' ],
        'non-operating income' => [ 'interest income' ],
        'net non-operating income (expense)' => [ 'non-operating income', 'non-operating expense' ],
        'net other income (expense)' => [ 'other income', 'other expense' ],
        'total unusual items' => [ 'unusual income', 'unusual expense' ],
        'pretax income' => [ 'operating income', 'net non-operating income (expense)', 'net other income (expense)' ],
        #'net income' => [ 'pretax income', 'tax provision' ]
    }
);




has %.params = (
    'income' => {
        'gross profit' => [ 'gross margin', 'gross income', 'sales profit' ],
        'selling general and administrative expenses' => [
            'selling general and administration expenses',
            'sales general and administration expenses',
            # ...
        ],
        'sales revenue' => [ 'revenue' ],
        'cost of revenue' => [ 'cost of goods sold', 'cost of sales' ],
        'operating revenu' => [ 'operating income' ],
        'net income' => [ 'net earnings' ]
    }
);

has Str $.sheet_name is rw; # 'balance', 'cashflow', 'income'
has @.to_identify is rw; # these will be the structure rows determined by Identifier_Structure
has @.exp_eqns is rw;

has $.line_count is rw = 0;
has %.cache is rw;

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


    # Algorithm as follows
    #
    # 1. loop over "spreadsheet" params (ie those on the actual spreadsheet)
    # and compare with "database" params (ie those we have listed), record
    # the best match and best score in each case.
    #
    # 2. if we encounter a 100% match then mark this field "identified" and
    # drop into analysing the relationship.
    #
    # If this field is the total in a relationship, use "find_best_combo" on
    # the components to identify the component fields. This will involve
    # checking each equation on the sheet_param_rel database table that matches
    # the parameter. (Should be a handful of possible equations)
    #
    # We should code in a "component matching cut-off" normalised score for the component
    # matching, below which we decide the components are NOT identified.
    # Initially we can set this to 0 (ie accept whatever best match), but
    # can use it to experiment with
    #
    # We can skip equations that are "bound" and have MORE
    # components than the spreadsheet equations (but not less, because the
    # spreadsheet might just not show parameters that have zero value)
    #
    # FOR IMPLEMENTATION LATER (but consider it now)
    # repeat this same process but considering the 100% identified param
    # as a *component* in an equation. Loop over the spreadsheet equations
    # it appears in and compare to database equations it appears in. Use
    # match to identify the other components in the equation + the total param
    #
    # 3. Once we reach the end of the loop (over spreadsheet params) we know
    # there are no 100% matches left. We also know the best match and best score
    # for each unidentified param. Start with the unidentified param which has the
    # best score, call it "identified", then repeat step 2. Continue picking the
    # next best score, until this score is less than a chosen "param matching cut-off"
    # At this point we decide we cannot identify any more spreadsheet parameters.
    #
    # 4. Final step: can we use the known equations to identify any missing
    # parameters? Loop over the list of parameters we are trying to collect
    # For any that are missing, is there an equation where all other parameters are
    # identified? Then deduce the value.

}
