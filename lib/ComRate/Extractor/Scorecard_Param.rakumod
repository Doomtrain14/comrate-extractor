use v6;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Scorecard;

unit class ComRate::Extractor::Scorecard_Param is ComRate::Extractor::Scorecard;

has @.synonyms is rw;

method evaluate{
    die "evaluate called but parameter type not specified" unless $.type;

    my $score = 0;

    for @.synonyms -> $synonym {
        #say "   synonym: $synonym";
        #my $syn_score = $.py.call('__main__','compare',$.input.lc,$synonym.lc);
        my $syn_score = $.ratio( $.input.lc, $synonym.lc );
        $score = $syn_score if $syn_score > $score;
    }

    #say "Scorecard_Param score: $score";
    return $score;
}
