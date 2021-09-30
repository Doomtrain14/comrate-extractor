use v6;
use ComRate::Extractor::Scorecard_Sheet;

unit class ComRate::Extractor::Scorecard_Sheet_Balance is ComRate::Extractor::Scorecard_Sheet;

has @.dictionary = [
    'Balance Sheet',
    'Balance Statement',
    'Statement of Balance',
    'Balance',
    'BS'
];
