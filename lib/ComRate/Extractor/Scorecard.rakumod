use v6;
use ComRate::Extractor::Essentials;
#no precompilation;
#use Inline::Python;
use Text::Levenshtein;
use Data::Dump;


unit class ComRate::Extractor::Scorecard;

has ComRate::Extractor::Essentials $.ess is required;
has $.type is rw;
has $.score is rw;
has $.input is rw;

method ratio( $input, $target ){

    my $longest = $input.chars;
    $longest = $target.chars if $target.chars > $longest;
    #say "longest: " ~ Dump( $longest);

    my $lev = distance( $input, $target )[0];
    #say "lev: " ~ Dump( $lev );

    my $m = $lev / $longest;
    my $rat = 100 * ( 1 - ( $lev / $longest ) );
    #say "lev $lev longest $longest m $m rat $rat";

    return $rat;
}


method best_ratio( $input, @dictionary ){

    my %best = (
        score => 0,
        di => Nil
    );

    for @dictionary -> $di {
        my $score = $.ratio( $input, $di );
        #say "input $input di: $di score: $score";

        if $score > %best<score> {
            %best<score> = $score;
            %best<di> = $di
        }
    }

    #say "input $input best ratio: %best<score> di: %best<di>";
    #say "dictionary: " ~ Dump( @dictionary );
    return %best<score>;
}
