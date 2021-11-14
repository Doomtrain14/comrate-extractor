use Red:ver<0.1.40>:api<2>;

model ComRate::Extractor::Schema::SheetSynonym is table<sheet_synonym>{
    has UInt    $!id            is serial;
    has Str     $.synonym       is column;
    has UInt    $.sheet_id      is referencing(
        *.id,
        :model<ComRate::Extractor::Schema::Sheet>
    );

    has         $.sheet         is relationship(
        *.sheet_id,
        :model<ComRate::Extractor::Schema::Sheet>
    );
}
