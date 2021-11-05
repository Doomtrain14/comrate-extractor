use Red:api<2>;

model ComRate::Extractor::Schema::SheetParamEqnComp is table<sheet_param_eqn_comp> {
    has UInt    $!id                is serial;
    has UInt    $!eqn_id            is referencing(
        *.id,
        :model<ComRate::Extractor::Schema::SheetParamEqn>
    );

    has UInt    $!param_id          is referencing(
        *.id,
        :model<ComRate::Extractor::Schema::SheetParam>
    );
}
