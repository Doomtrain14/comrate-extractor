use v6;
use Spreadsheet::XLSX;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Worksheet;

unit class ComRate::Extractor::Workbook;

has ComRate::Extractor::Essentials $.ess is required;

has Str $.filename is required;
has $.xlsx;
has @.sheets;

method load {

	say "filename: " ~ $!filename;
	my $m = self.filename ~~ / \. (<-[\.]>+) $ /;
	my $ext = $m.list[0];
	say "ext: " ~ $ext;

	if $ext eq 'xlsx' {

		#my Str @frags = (self.filename);
		my $path = self.ess.path( 'data', $!filename );
		$!xlsx = Spreadsheet::XLSX.load( $path );

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
