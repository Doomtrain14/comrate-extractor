use v6;
use ComRate::Extractor::Essentials;
use Spreadsheet::XLSX::Worksheet;

unit class ComRate::Extractor::Worksheet;

has ComRate::Extractor::Essentials $.ess is required;

has Spreadsheet::XLSX::Worksheet $.xlsx;
has @.sections;

method name {
    return $.xlsx.name;
}
