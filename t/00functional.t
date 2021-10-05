# pseudocode test examples - needs (a lot of) adapting and extending

use v6;
use Test;
use Comrate::Extractor::Essentials;
use Comrate::Extractor::Workbook;
use Comrate::Extractor;
use Comrate::Extractor::Identifier_Sheet;

my $filename = 'AAPL-income.xlsx';
my $ess = ComRate::Extractor::Essentials.new;
my $workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
my $xr = ComRate::Extractor.new(:$ess,:$workbook);

$xr.extract;

# test final output:

is-deeply $xr.results, {
    income => {
        "sales revenue" => 233_715,
        "cost of goods sold" => 128_832,
        "gross profit" => 93_626,
        "sales general and admin expenses" => -14_329,
        "operating profit (EBIT)" => 73_248,
        "non-operating income" => Nil,
        "unusual expenses" => 0,
        "interest expense" => -733,
        "earnings before tax" => 72_515,
        "income tax expense" => 19_121,
        "net income" => 53394
    }
}, "Overall results";

my $sheets = $xr.workbook.sheets;
my $sections = $sheets[0].sections;

# We should check "sections" have been correctly identified
# in the worksheet. NB. "as_hash" is just hypothetical, a
# "section" will be an object and we can test the output
# values in whatever way is convenient

is-deeply $sections[0].as_hash, {
    title => Nil,
    data => [{
        name => "Operating Revenue",
        value => 233_715,
    }, {
        name => "Adjustments to Revenue",
        value => "N/A"
    }, {
       name => "Cost of Revenue",
       value => 128_832
    }],
    total => {
        name => "Gross Operating Profit"
        value => 93_626
    }
}, "first section";

# We should check structure has been
# identified correctly - ie which sections
# are contained within which sections. (
# as_hash hypothetical again)

my $structure = $sheets[0].structure;
is-deeply $structure[0].as_hash, {
    7 => {
        6 => [0,1,2,3,4,5]
    }
}, "Worksheet structure";

# We will need other intermediate output tests

# We should also have tests for correct identification
# of worksheets (functionality already exists to
# do this via simply looking at the worksheet name).
#
# We expect the input workbook to have income, cashflow
# and balance statements - ie 3 worksheets. However,
# we should accept less than 3, in which case we best
# guess which 1 or 2 out of the 3 they are - or more
# than 3 - in which case we best guess which are the correct
# 3. (Again, this is already done based on worksheet name)

$filename = 'BS_PL_Summary.xlsx';
$workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
my $idr = Comrate::Extractor::Identifier_Sheet.new( :$ess,
    to_identify => $workbook.sheets
);

$idr.identify;
is-deeply $idr.identified, {
    cashflow => 0,
    balance => 2,
    income => 8
}, "Worksheet identification";
