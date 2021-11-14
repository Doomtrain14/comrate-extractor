use Red:ver<0.1.40>:api<2>;

model ComRate::Extractor::Schema::SheetParamSynonym is table<sheet_param_synonym> {
    has UInt    $.id                is serial;
    has Str     $.synonym           is column;
    has UInt    $.sheet_param_id     is referencing(
        *.id,
        :model<ComRate::Extractor::Schema::SheetParam>
    );
    has         $.sheet_param        is relationship(
        *.sheet_param_id,
        :model<ComRate::Extractor::Schema::SheetParam>
    );
}
