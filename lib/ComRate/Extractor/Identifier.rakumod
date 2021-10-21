use v6;
use ComRate::Extractor::Scorecard_Param;
use ComRate::Extractor::Scorecard_Sheet;
use ComRate::Extractor::Essentials;


unit class ComRate::Extractor::Identifier;

has ComRate::Extractor::Essentials $.ess is required;

has @.options is rw;
has @.scores is rw;
has @.to_identify is rw;
has %.identified is rw;

has @.combo is rw;

method find_best_combo ($sc_name) {

	die 'identify called, but "options" not provided' unless @.options;
	die 'identify called, but "to_identify" not provided' unless @.to_identify;

	for self.options.kv -> $opt_i, $option {

        my $idr_class = "ComRate::Extractor::Scorecard_" ~ $sc_name;
        #require $idr_class;
		my $scorecard = ::($idr_class).new: :$.ess;
        $scorecard.type = $option;

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
    #say "combo: " ~ @.combo.gist;
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
