use v6;
use ComRate::Extractor::Essentials;
#no precompilation;
use Inline::Python;

unit class ComRate::Extractor::Scorecard;

has ComRate::Extractor::Essentials $.ess is required;
has $.type is rw;
has $.score is rw;
has $.input is rw;

has Inline::Python $.py = sub{
   my $py = Inline::Python.new;
   $py.run(q:heredoc/PYTHON/);
from fuzzywuzzy import process, fuzz

def score(input, *dictionary):
   highest = process.extractOne(input,dictionary)
   return highest[1]

def compare(input, target):
   return fuzz.ratio( input, target )
PYTHON

   return $py;
}();
