# pseudocode test examples - needs (a lot of) adapting and extending

use v6;
use Test;
use ComRate::Extractor::Essentials;
use ComRate::Extractor::Workbook;
use ComRate::Extractor;
use ComRate::Extractor::Identifier_Sheet;

my $ess = ComRate::Extractor::Essentials.new;

my $filename = 'Annual_IncomeStatement_AAPL.xlsx';
my $workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
my $xr = ComRate::Extractor.new(:$ess,:$workbook);

my $results = $xr.extract;

# test final output:

is-deeply $results, {
    income => {
        "EBIT"                                        => "69964",
        "cost of revenue"                             => "-169559",
        "gross profit"                                => "104956",
        "interest expense"                            => "-2873",
        "net income"                                  => "57411",
        "pretax income"                               => "67091",
        "selling general and administrative expenses" => "-19916",
      },
}, "Overall results - Income";


$filename = 'Annual_BalanceSheet_AAPL.xlsx';
$workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
$xr = ComRate::Extractor.new(:$ess,:$workbook);
$results = $xr.extract;

is-deeply $results, {
    balance => {
        "accounts payable"             => "42296",
        "accounts receivable"          => "16120",
        "accrued expenses payable"     => "42296",
        "accumulated depreciation"     => "-66760",
        "capital stock"                => "65745",
        "cash"                         => "17773",
        "intangible assets"            => "-",
        "inventory"                    => "4061",
        "other long term liabilities"  => "26320",
        "other short term liabilities" => "42684",
        "property plant and equipment" => "36766",
        "retained earnings"            => "14966",
        "stockholders equity"          => "65339",
        "total assets"                 => "323888",
        "total current assets"         => "143713",
        "total current liabilities"    => "105392",
        "total long term liabilities"  => "153157",
    }
}, "Overall results - Balance";

my $sheets = $xr.workbook.sheets;


$filename = 'Annual_CashFlow_AAPL.xlsx';
$workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
$xr = ComRate::Extractor.new(:$ess,:$workbook);
$results = $xr.extract;

is-deeply $results, {
    "cashflow" => {
       "capital expenditure"                    => "-7309",
       "depreciation and amortisation expenses" => "11056",
       "investment in other assets"             => "-791",
       "net cash from investing activities"     => "-4289",
       "net cash from operating activities"     => "80674",
       "net income (loss)"                      => "57411",
       "net increase in cash and equivalents"   => "-10435",
       "other financing activities"             => "-86820",
       "proceeds from issuance of debt"         => "2499",
       "repayments of long term debt"           => "-12629"
     }
}, "Overall results - Cashflow";

$filename = 'BS_PL_Summary.xlsx';
$workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
$workbook.load;
$workbook.get_sheets;
say "sheets: " ~ $workbook.sheets.elems;
my $idr = ComRate::Extractor::Identifier_Sheet.new(
    :$ess,
    to_identify => $workbook.sheets,
    options => ['income','balance','cashflow']
);

$idr.identify;
is-deeply $idr.identified, {
    cashflow => 0,
    balance => 2,
    income => 8
}, "Worksheet identification";


done-testing;
