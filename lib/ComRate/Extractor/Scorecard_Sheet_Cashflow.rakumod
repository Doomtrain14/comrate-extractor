use v6;
use ComRate::Extractor::Scorecard_Sheet;

unit class ComRate::Extractor::Scorecard_Sheet_Cashflow is ComRate::Extractor::Scorecard_Sheet;

has @.dictionary = [
    'Cashflow Sheet',
    'Cashflow Statement',
    'Cashflow',
    'CF'
];
