use v6;
use Data::Dump;
use ComRate::Extractor::Identifier;
use ComRate::Extractor::Worksheet;
use ComRate::Extractor::Scorecard_Sheet_Cashflow;
use ComRate::Extractor::Scorecard_Sheet_Income;
use ComRate::Extractor::Scorecard_Sheet_Balance;

constant Worksheet = ComRate::Extractor::Worksheet;
constant Identifier = ComRate::Extractor::Identifier;

unit class ComRate::Extractor::Identifier_Sheet is Identifier;

has Worksheet @.to_identify is rw;

# the below "identify" method should be moved to the parent class
# ie ComRate::Extractor::Identifier and made generic
# it can be called "find_best_combo" as it finds the best
# (ie highest scoring) combination from a test set. Currently it
# evaluates score but does not return it (or stash it). We need to
# (a) adjust the method so the score is returned
# (b) also return a NORMALISED score. This will be
#
# sum( scores of best scoring combo ) / num elements in combo
#
# however if the number of elements to identify is LESS THAN
# the number of options then we should pad the missing options with
# the expected average score for each missing option. If we are
# using fuzzywuzzy which gives a score between 0 and 100 we can use
# 50 for the time being (I think not actually correct, but we can
# update when we have more info). However, we need to add a method to
# the scorecord(s) which returns this value (method could be called
# "average_value"? )
#
# find_best_combo should take @options, @to_identify and the name
# of the scoring module.
#
# I am thinking perhaps we should ditch having separate modules
# for Balance, Cashflow and Income - ie just have
# ComRate::Extractor::Scorecard_Sheet
# and pass the sheet name as a variable
# OR EVEN perhaps ditch scorecards altogether and integrate
# with the Identifier class?
# 

method identify {

	die 'identify called, but "options" not provided' unless @.options;
	die 'identify called, but "to_identify" not provided' unless @.to_identify;

	for self.options.kv -> $opt_i, $option {

        my $idr_class = "ComRate::Extractor::Scorecard_Sheet_" ~ $option.tclc;
		my $scorecard = ::($idr_class).new;

        my @opt_scores;
		for self.to_identify.kv -> $sh_i, $sheet {

			$scorecard.input = $sheet;
			my $score = $scorecard.evaluate;

            my %score_inf = (
                sheet_index => $sh_i,
                score => $score
            );

			@opt_scores[ $sh_i ] = %score_inf;
		}

        @opt_scores = @opt_scores.sort({ $^b<score> <=> $^a<score> });

        self.scores[ $opt_i ] = @opt_scores;
	}


	my @best_combo;
	my $best_total = 0;

	@.combo = [];

	@.combo.push(-1) for @.options;

	my $count = 0;
	repeat {

		my $total = 0;
		for @.combo.kv -> $opt_i, $pos_i {
            next if $pos_i == -1;
            my $score = self.scores[ $opt_i ][ $pos_i ]<score>;
			$total += $score;
		}

		if $total > $best_total {
			@best_combo = @.combo;
            $best_total = $total;
		}
	}  while self.increment_combo;

	self.identified = {};

    for @best_combo.kv -> $opt_i, $pos_i {
        next if $pos_i == -1;
        my $sh_i = @.scores[ $opt_i ][ $pos_i ]<sheet_index>;
        self.identified{ @.options[ $opt_i ] } = $sh_i;
    }
}


method increment_combo{

	my $inc_index = 0;
	my $inc_ret = self.inc_combo_index( $inc_index );
    return $inc_ret;

}


method inc_combo_index( Int $inc_index ) {

	my $more = True;

    my $max_opt = self.options.end;
    my $max_idy = self.to_identify.end;
    my $max_index = $max_opt > $max_idy ?? $max_idy !! $max_opt;

	if @.combo[ $inc_index ] < $max_index {
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
		return False;
	} else {
		@.combo[ $inc_index ] = -1;
		my $next_index = $inc_index + 1;
		return self.inc_combo_index( $next_index );
	}
}



method does_combo_clash{

	my $clash = False;
	my %seen = ();
	for self.combo.kv -> $opt_i, $pos_i {
        next if $pos_i == -1;
        my $sh_i = @.scores[ $opt_i ][ $pos_i ]<sheet_index>;
		if %seen{ $sh_i } {
			$clash = True;
			last;
		}

		%seen{ $sh_i } = True;
	}
	return $clash;
}
