use v6;
use Red:api<2>;
use ComRate::Extractor::Identifier::Schema;

my $dbhost = 'localhost';
my $dbname = 'comrate';
my $dbuser = 'comrate';
my $*RED-DEBUG = 1;
#my $*RED-DB = database "Pg host={$dbhost} dbname={$dbname} user={$dbuser}";
red-defaults 'SQLite', :database<./comrate.db>;

identifier_schema.drop.create;
