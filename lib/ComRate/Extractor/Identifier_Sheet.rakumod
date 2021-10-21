use v6;
use Data::Dump;
use ComRate::Extractor::Identifier;
use ComRate::Extractor::Worksheet;


constant Worksheet = ComRate::Extractor::Worksheet;
constant Identifier = ComRate::Extractor::Identifier;

unit class ComRate::Extractor::Identifier_Sheet is Identifier;

has Worksheet @.to_identify is rw;


method identify {

	die 'identify called, but "options" not provided' unless @.options;
	die 'identify called, but "to_identify" not provided' unless @.to_identify;

    $.find_best_combo( 'Sheet' );

}
