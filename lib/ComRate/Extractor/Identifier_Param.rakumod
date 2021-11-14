use v6;
use ComRate::Extractor::Scorecard_Param;
use ComRate::Extractor::Identifier;
use Data::Dump;
use ComRate::Extractor::Schema::SheetParamEqn;
constant Identifier = ComRate::Extractor::Identifier;

unit class ComRate::Extractor::Identifier_Param is Identifier;

has Str $.sheet_name is rw; # 'balance', 'cashflow', 'income'
has %.structure is rw;
has @.exp_eqns is rw;

has $.line_count is rw = 0;
has %.cache is rw;

has @.key_fields is rw;
has %.collect is rw;

has %.index_ws is rw;

method index{

    # %.equations needs replacing with input from the yaml
    # we also will need to add in "eqn_type", which should
    # be "bound" only if all constituent equations are "bound"
    # but "unbound" if any one is "unbound"

    #die "before";

#    ComRate::Extractor::Schema::SheetParamEqn.^all.grep({ True }).delete;

#    die "dead";



    $.ess.dbi.set('SheetParamEqnComp').delete;
    $.ess.dbi.set('SheetParamEqn').delete;
    $.ess.dbi.set('SheetParam').delete;

    for |$.ess.conf<params>.kv -> $sheet_name, %sheet_info {

        my %sheet_r = $.ess.dbi.set('Sheet').find({ name => $sheet_name });

        for |%sheet_info<params>.kv -> $param_name, %param_info {
            $.ess.dbi.set('SheetParam').create({
                sheet_id => %sheet_r<id>,
                name => $param_name,
                collect => %param_info<collect>,
                expected_sign => %param_info<expected_sign>
            });
        }

        #die "finished sheet_param";

        %.index_ws<sheet_id> = %sheet_r<id>;

        for |%sheet_info<equations>.kv -> $param_name, %param_info {

#    for |%.equations<income>.kv -> $param, @comps {
          self.expand_comps(
              $sheet_name,
              $param_name,
              %param_info<components>,
              %param_info<eqn_type>
          );
        }
        say "ENDDDDDD";
    }

}


method expand_comps( $sheet_name, $param, @comps, $eqn_type ) {
    return if self.seen( $param, @comps );
    self.write_output( $param, @comps, $eqn_type );

    for @comps.kv -> $i, $comp {
        my @comps_exp = @comps;

#        if %.equations<income>{ $comp } {

        my $eqn = $.ess.conf<params>{ $sheet_name }<equations>{ $comp };

        if $eqn {
            #my @child_comps = |%.equations<income>{ $comp };
            my @child_comps = $eqn<components>;
            my $recurse = False;
            for @child_comps -> $child_comp {
                if $param eq $child_comp { $recurse = True; last }
                if @comps_exp.grep: $child_comp { $recurse = True; last }
            }

            if not $recurse {
                my $eqn_type_exp = $eqn_type;
                $eqn_type_exp = 'unbound' if $eqn<eqn_type> eq 'unbound';
                @comps_exp.splice( $i, 1, |@child_comps );
                self.expand_comps(
                    $sheet_name,
                    $param,
                    @comps_exp,
                    $eqn_type_exp
                );
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

method write_output( $param, @comps, $eqn_type ){

    #write to the database here

    say "0: $param";

    my %param_r = $.ess.dbi.set('SheetParam').find({
        sheet_id => %.index_ws<sheet_id>,
        name => $param
    });

    say "1: $param";

    # unless $param_r {
    #     $param_r = $.ess.schema('SheetParam', 'create', {
    #         sheet_id => %.index_ws<sheet_id>,
    #         name => $param
    #     });
    # }

    my %eqn_r = $.ess.dbi.set('SheetParamEqn').create({
        param_id => %param_r<id>,
        num_comps => @comps.elems,
        eqn_type => $eqn_type
    });

    say "eqn_r: " ~ Dump( %eqn_r );

    say "2: $param";

    for @comps -> $comp {

        my %comp_r = $.ess.dbi.set('SheetParam').find-or-create({
            sheet_id => %.index_ws<sheet_id>,
            name => $comp
        });

       $.ess.dbi.set('SheetParamEqnComp').create({
           eqn_id => %eqn_r<id>,
           param_id => %comp_r<id>
       });

    }

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
    #    param_id

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

    self.identify_missing;

}


method identify_missing {

    my %sheet_r = $.ess.dbi.set('Sheet').find({
        name => $.sheet_name
    });

    my @to-collect = $.ess.dbi.set('SheetParam').search({
        collect => True,
        sheet_id => %sheet_r<id>
    });

    for @to-collect -> %param {
        next if %.collect{ %param<name> };
        say "missing: %param<name>";
        my %param_r = $.ess.dbi.set('SheetParam').find({
            name => %param<name>,
            sheet_id => %sheet_r<id>
        });

        say "param_r: " ~ Dump( %param_r );

        my @eqn_rs = $.ess.dbi.set('SheetParamEqn').search({
            param_id => %param_r<id>,
            eqn_type => 'bound'
        });

        say "found {@eqn_rs.elems} equations with %param_r<name> as subject";

        for @eqn_rs -> %eqn_r {

            say "eqn_r: " ~ Dump( %eqn_r );

            my @comps_rs = $.ess.dbi.set('SheetParamEqnComp').search({
                eqn_id => %eqn_r<id>
            }, {
              join => {
                'SheetParam' => {
                    'param_id' => 'id'
                }
            }});

            my $helpful = True;
            my $total = 0;
            for @comps_rs -> %comps_r {

                say "comp name: %comps_r<name>";

                if %.identified{ %comps_r<name> } {
                    $total += %.identified{ %comps_r<name> }<value>;
                } else {
                    $helpful = False;
                    last;
                }
            }

            if $helpful {
                die "helfule!!"
                %.collect{ %param<name> } = {
                    value => $total
                };
                last;
            }
        }
    }
}
