use v6;
use ComRate::Extractor::Scorecard;
use ComRate::Extractor::Essentials;

unit class ComRate::Extractor::Scorecard_Param is ComRate::Extractor::Scorecard;

has @.synonyms is rw;

method evaluate{
    die "evaluate called but parameter type not specified" unless $.type;

    my $score = 0;

    for @.synonyms -> $synonym {
        my $syn_score = $.py.call('__main__','compare',$.input.lc,$synonym.lc);
        $score = $syn_score if $syn_score > $score;
    }
    
    return $score;
}
