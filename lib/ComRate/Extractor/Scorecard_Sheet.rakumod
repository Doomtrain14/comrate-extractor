use v6;
use ComRate::Extractor::Scorecard;

unit class ComRate::Extractor::Scorecard_Sheet is ComRate::Extractor::Scorecard;

has %.synonyms = {
    'balance' => [
        'Balance Sheet',
        'Balance Statement',
        'Statement of Balance',
        'Balance',
        'BS'
    ],
    'cashflow' => [
        'Cashflow Sheet',
        'Cashflow Statement',
        'Cashflow',
        'CF'
    ],
    'income' => [
        'Income Sheet',
        'Income Statement',
        'Statement of Income',
        'Income',
        'Profit and Loss Sheet',
        'Profit and Loss Statement',
        'Profit and Loss'
    ]
};

method evaluate {
    die "evaluate called but worksheet type not specified" unless $.type;
    my @.dictionary = |%.synonyms{ $.type };
    #my $score = $.py.call('__main__','score',$.input.name,@.dictionary);
    my $score = $.best_ratio( $.input.name, @.dictionary );
    $.score = $score;
    #say "Scorecard_Sheet score: $score";
    return $score;
}
