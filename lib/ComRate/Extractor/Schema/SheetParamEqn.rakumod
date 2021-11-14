use Red:ver<0.1.40>:api<2>;

model ComRate::Extractor::Schema::SheetParamEqn is table<sheet_param_eqn> {
    has UInt    $.id                is serial;
    has UInt    $.param_id          is referencing(
      *.id,
      :model<ComRate::Extractor::Schema::SheetParam>
    );
    has Str     $.eqn_type          is column;
    has Int     $.num_comps         is column;
    has         @.components        is relationship(
        *.sheetparameqn_id,
        :model<ComRate::Extractor::Schema::SheetParamEqnComp>
    );
}
