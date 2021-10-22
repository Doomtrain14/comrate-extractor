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


# Use SQLite for initial dev work
$dbtype = 'SQLite';

my $*RED-DEBUG = 1;
#my $*RED-DB = database "{$dbtype host={$dbhost} dbname={$dbname} user={$dbuser}";
red-defaults $dbtype, :database<./comrate.db>;

identifier_schema.drop.create;

my %param = $ess.conf<params>;

for %param.kv -> $sheet_name, $sv {
    say "sheet_name: $sheet_name";
    my $sheet = Sheet.^create: :name($sheet_name);
    say "sheet: {$sheet.raku}";

    my %params;

    for $sv<params>.kv -> $param_name, $pv {
        say "param_name: $param_name";
        say "synonyms: $pv<synonyms>";
        say "expected_sign: $pv<expected_sign>";
        say "collect: $pv<collect>";
        
        my @synonyms = $pv<synonyms>.Array.map: { %( synonym => $_ ) };
        my $sp = $sheet.params.create(
            :name($param_name),
            :sign($pv<expected_sign>),
            :collect($pv<collect>),
            :synonyms(@synonyms)
        );
        %params{$param_name} = $sp;
    }

    for $sv<equations>.kv -> $param_name, $ev {
        say "equation";
        say "\tparam_name: $param_name";
        say "\teqn_type: {$sv<equations>{$param_name}<eqn_type>}";
        say "\tcomponents: {$sv<equations>{$param_name}<components>}";
        my @components = $sv<equations>{$param_name}<components>
            .Array.map: { %( param => %params{$_} ) };

        my $eqn = %params{$param_name}.equation.^create(
            :eqn_type($sv<equations>{$param_name}<eqn_type>),
            :components(@components)
        );
        exit;
    }
}

