use v6;
use ComRate::Extractor::Essentials;

unit class ComRate::Extractor::Worksheet::Cell;

has $.xlsx is rw;

method value {
    return $.xlsx ?? $.xlsx.value !! Nil;
}

method formula {
    return $.xlsx<Formula>;
}

method type {
    return $.xlsx ?? $.xlsx.type !! Nil;
}
