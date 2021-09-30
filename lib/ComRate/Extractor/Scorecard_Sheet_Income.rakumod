use v6;
use ComRate::Extractor::Scorecard_Sheet;

unit class ComRate::Extractor::Scorecard_Sheet_Income is ComRate::Extractor::Scorecard_Sheet;

has @.dictionary is rw = [
        'Income Sheet',
        'Income Statement',
        'Statement of Income',
        'Income',
        'Profit and Loss Sheet',
        'Profit and Loss Statement',
        'Profit and Loss'
        # ...
    ];
