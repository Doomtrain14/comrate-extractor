use v6;
use Spreadsheet::ParseXLSX:from<Perl5>;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Worksheet;
use Data::Dump;

unit class ComRate::Extractor::Workbook;

has ComRate::Extractor::Essentials $.ess is required;

has Str $.filename is required;
has $.xlsx;
has @.sheets;

method load {

	my $m = self.filename ~~ / \. (<-[\.]>+) $ /;
	my $ext = $m.list[0];

	if $ext eq 'xlsx' {

		my $path = self.ess.path( 'data', $!filename );
		my $parser = Spreadsheet::ParseXLSX.new;
        $!xlsx = $parser.parse( $path.absolute );

	} else {

		die "File extension not recognised";

	}
}

method get_sheets {

	if self.xlsx {

		my @sheets;
		for self.xlsx.worksheets -> $worksheet {
			@sheets.push: ComRate::Extractor::Worksheet.new(
				ess => self.ess,
				xlsx => $worksheet
			);
		}

		self.sheets = @sheets;

	} else {

		die "No workbook";

	}

}
