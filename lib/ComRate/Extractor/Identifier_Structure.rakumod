use v6;
use ComRate::Extractor::Identifier;

unit class ComRate::Extractor::Identifier_Structure is ComRate::Extractor::Identifier;

has $.structure is rw;

method identify {
    say "ELEMS: " ~ self.to_identify.elems;
}
