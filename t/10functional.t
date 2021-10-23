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
        "earnings before tax"                         => "67091",
        "gross profit"                                => "104956",
        "income tax expense"                          => "-9680",
        "interest expense"                            => "-2873",
        "net income"                                  => "57411",
        "non-operating income"                        => "890",
        "sales revenue"                               => "274515",
        "selling general and administrative expenses" => "-19916"
      }
}, "Overall results - Income";


$filename = 'Annual_BalanceSheet_AAPL.xlsx';
$workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
$xr = ComRate::Extractor.new(:$ess,:$workbook);
$results = $xr.extract;

is-deeply $results, {
    balance => {
        "accounts payable"              => "42296",
        "accounts receivable"           => "16120",
        "accrued expenses payable"      => "42296",
        "accumulated depreciation"      => "-66760",
        "capital stock"                 => "65745",
        "cash"                          => "17773",
        "intangible assets"             => "-",
        "inventory"                     => "4061".Str,
        "net fixed assets"              => "-".Str,
        "other long term liabilities"   => "26320".Str,
        "other short term liabilities"  => "42684".Str,
        "property plant and equipment"  => "36766".Str,
        "retained earnings"             => "14966".Str,
        "short term notes payable"      => "-".Str,
        "stockholders equity"           => "65339".Str,
        "total assets"                  => "323888".Str,
        "total current assets"          => "143713".Str,
        "total current liabilities"     => "105392".Str,
        "total non current liabilities" => "153157".Str,
      }
}, "Overall results - Balance";

my $sheets = $xr.workbook.sheets;


$filename = 'Annual_CashFlow_AAPL.xlsx';
$workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
$xr = ComRate::Extractor.new(:$ess,:$workbook);
$results = $xr.extract;

is-deeply $results, {
    cashflow => {
      "capital expenditure"                    => "-7309",
      "depreciation and amortisation expenses" => "11056",
      "exchange rate fluctuations"             => "-",
      "investment in other assets"             => "-791",
      "net cash from investing activities"     => "-4289",
      "net cash from operating activities"     => "80674",
      "net income (loss)"                      => "57411",
      "net increase in cash and equivalents"   => "-10435",
      "other financing activities"             => "-86820",
      "proceeds from issuance of debt"         => "2499",
      "repayments of long term debt"           => "-12629"
    },

}, "Overall results - Cashflow";

$filename = 'BS_PL_Summary.xlsx';
$workbook = ComRate::Extractor::Workbook.new(:$ess,:$filename);
$workbook.load;
$workbook.get_sheets;
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
