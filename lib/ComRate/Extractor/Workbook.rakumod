use v6;
use Spreadsheet::ParseXLSX:from<Perl5>;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Worksheet;
use Data::Dump;

constant Worksheet = ComRate::Extractor::Worksheet;

unit class ComRate::Extractor::Workbook;

has ComRate::Extractor::Essentials $.ess is required;

has Str $.filename is required;
has $.xlsx;
has Worksheet @.sheets;

method load {

	my $m = self.filename ~~ / \. (<-[\.]>+) $ /;
	my $ext = $m.list[0];

	if $ext eq 'xlsx' {

		my $ddir = self.ess.conf<main><dir><data> // 'data';
#		say $ddir; die;
		my $path = self.ess.path( $ddir, $!filename );
#		my $path = self.ess.path( 'data', $!filename );
		my $parser = Spreadsheet::ParseXLSX.new;
        say "path: " ~ $path.absolute;
        $!xlsx = $parser.parse( $path.absolute );

	} else {

		die "File extension not recognised";

	}
}

method get_sheets {

	if self.xlsx {

		my Worksheet @sheets = ();
		for self.xlsx.worksheets -> $worksheet {
			@sheets.push( Worksheet.new(
				ess => self.ess,
				xlsx => $worksheet
			) );
		}

		self.sheets = @sheets;

	} else {

		die "No workbook";

	}

}
