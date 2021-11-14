use v6;

use Red:ver<0.1.40>:api<2>;

model ComRate::Extractor::Schema::Sheet is table<sheet> {
    has UInt    $.id        is serial;
    has Str     $.name      is column{ :unique };
#    has         @.synonyms  is relationship(
#        *.sheet_id,
#        :model<ComRate::Extractor::Schema::SheetSynonym>,
        #:require<ComRate::Extractor::Identifier::Schema>
#    );
    has         @.params    is relationship(
        *.sheet_id,
        :model<ComRate::Extractor::Schema::SheetParam>,
        #:require<ComRate::Extractor::Identifier::Schema>
    );
}
