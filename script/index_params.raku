use v6;
use Red:api<2>;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Identifier::Schema;

my $ess = ComRate::Extractor::Essentials.new;

my %db = $ess.conf<main><database> || %();
my $dbtype     = %db<type>     || 'Pg';
my $dbname     = %db<name>     || 'comrate';
my $dbuser     = %db<user>     || 'comrate';
my $dbpassword = %db<password> || 'comrate';
my $dbhost     = %db<host>     || 'localhost';

my %param = $ess.conf<params>;

# Use SQLite for time being
$dbtype = 'SQLite';

my $*RED-DEBUG = 1;
#my $*RED-DB = database "{$dbtype host={$dbhost} dbname={$dbname} user={$dbuser}";
red-defaults $dbtype, :database<./comrate.db>;

identifier_schema.drop.create;
