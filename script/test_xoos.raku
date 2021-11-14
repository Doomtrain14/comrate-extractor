use v6;

use DB::Xoos;
use ComRate::Extractor::Model::Sheet;

my DB::Xoos $d=DB::Xoos.new;

say "d: " ~ $d.^methods.gist;

#$d.get-db;
#my %params = (
#    db => 'comrate_extractor',
#    user => 'comrate_user',
#    pass => 'WgUiPWQsV9x',
#    host => 'localhost',
#    port => '5432'
#);

$d.connect('pg://comrate_user:WgUiPWQsV9x@localhost:5432/comrate_extractor',
    options => { :dynamic-loading, prefix => 'ComRate::Extractor' }
);

$d.load-models;
#state $dbo;
#$dbo = $d.get-db( %params );
#$dbo.db.query('select 1;');

#say "dbo: " ~ $dbo.^methods.gist;

#my @lm = $dbo.loaded-models;
#say "lm: " ~ @lm.gist;

my $sheet = $d.model('Sheet');
my $new-sheet = $sheet.new-row;

say "done";
