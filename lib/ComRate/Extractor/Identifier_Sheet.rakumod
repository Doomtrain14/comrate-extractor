use v6;
use ComRate::Extractor::Identifier;
use Data::Dump;
#use ComRate::Extractor::Scorecard_Sheet_Cashflow;
#use ComRate::Extractor::Scorecard_Sheet_Income;
#use ComRate::Extractor::Scorecard_Sheet_Balance;

unit class ComRate::Extractor::Identifier_Sheet is ComRate::Extractor::Identifier;

method identify {

	die 'identify called, but "options" not provided' unless @.options;
	die 'identify called, but "to_identify" not provided' unless @.to_identify;

	for self.options.kv -> $opt_i, $option {

        say "option: $option";
        #next if $option eq 'cashflow';
        #next if $option eq 'income';

        my $idr_class = "ComRate::Extractor::Scorecard_Sheet_" ~ $option.tclc;
        require ::($idr_class);
		my $scorecard = ::($idr_class).new;

		self.scores[ $opt_i ] = [];

		for self.to_identify.kv -> $sh_i, $sheet {

			$scorecard.input = $sheet;
			my $score = $scorecard.evaluate;
			self.scores[ $opt_i ][ $sh_i ] = $score;

            say "FIRST opt_i $opt_i, sh_i $sh_i";
            say "FIRST score: " ~ self.scores[ $opt_i ][ $sh_i ];

		}
	}

    say "scores: " ~ Dump( @.scores );

	my @best_combo;
	my $best_total = 0;

	@.combo = [];

    say "ELEMS: " ~ @.scores.elems;
    for @.scores.kv -> $i,$score {
        say "$i: $score";
    }

	@.combo.push(-1) for @.scores;

	my $count = 0;
	repeat {

		my $total;
		for @.combo.kv -> $opt_i, $sh_i {
            next if $sh_i == -1;
            #say "opt_i $opt_i, sh_i $sh_i";
            #say "score: " ~ self.scores[ $opt_i ][ $sh_i ];
			$total += self.scores[ $opt_i ][ $sh_i ];
		}
        say "combo: " ~ @.combo.raku;
        say "total: $total";

		if $total > $best_total {
			@best_combo = @.combo;
            $best_total = $total;
		}
	}  while self.increment_combo;

    say "best_combo: " ~ Dump( @best_combo );
	self.identified = {};

    for @best_combo.kv -> $opt_i, $sh_i {
        next if $sh_i == -1;
        self.identified{ @.options[ $opt_i ] } = $sh_i;
    }
}


method increment_combo{

	my $inc_index = 0;
	my $inc_ret = self.inc_combo_index( $inc_index );
    say "inc_ret: $inc_ret";
    return $inc_ret;

}


method inc_combo_index( Int $inc_index ) {

	my $more = True;
    say "combo " ~ Dump( @.combo );
    #my @ti = @.to_identify;
    #say "to identify " ~ @ti.gist;
	if @.combo[ $inc_index ] < self.to_identify.end {
        say "less than";
        if self.combo[ $inc_index ] == -1 {
            self.combo[ $inc_index ] = 0;
        } else {
            self.combo[ $inc_index ]++;
        }

		if self.does_combo_clash {
			return self.inc_combo_index( $inc_index );
		} else {
			return True;
		}
	} elsif $inc_index == self.combo.end {
        say "equal";
		return False;
	} else {
        say "else";
		@.combo[ $inc_index ] = -1;
		my $next_index = $inc_index + 1;
		return self.inc_combo_index( $next_index );
	}
}



method does_combo_clash{

	my $clash = False;
	my %seen = ();
	for self.combo.kv -> $i, $ind {
		if $ind != -1 and %seen{ $ind } {
			$clash = True;
			last;
		}

		%seen{ $ind } = True;
	}
	return $clash;
}
