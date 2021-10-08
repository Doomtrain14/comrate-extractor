use v6;
use ComRate::Extractor::Essentials;

unit class ComRate::Extractor::Identifier;

has ComRate::Extractor::Essentials $.ess is required;

has @.options is rw;
has @.scores is rw;
has %.identified is rw;

has @.combo is rw;
