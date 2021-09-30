use v6;
use Inline::Python;
use ComRate::Extractor::Scorecard;

unit class ComRate::Extractor::Scorecard_Sheet is Comrate::Extractor::Scorecard;

has Inline::Python $.py = sub{
    my $py = Inline::Python.new;
    $py.run(q:heredoc/PYTHON/);
from fuzzywuzzy import process

def score(input, *dictionary):
    highest = process.extractOne(input,dictionary)
    return highest[1]
PYTHON

    return $py;
}();


method evaluate {
    my $score = $!py.call('__main__','score',$.input.name,@.dictionary);
    $.score = $score;
    return $score;
}
