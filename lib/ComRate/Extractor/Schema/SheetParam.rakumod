use Red:ver<0.1.40>:api<2>;

model ComRate::Extractor::Schema::SheetParam is table<sheet_param> {
    has UInt    $.id                is serial;
    has UInt    $.sheet_id          is referencing(
                                        *.id,
                                        :model<ComRate::Extractor::Schema::Sheet>,
                                    );

    has Str     $.name              is column;
    has Str     $.expected_sign     is column;
    has Int     $.collect           is column;
    has         $.sheet             is relationship(
                                        *.sheet_id,
                                        :model<ComRate::Extractor::Schema::Sheet>
                                    );

    has         @.synonyms          is relationship(
                                        *.sheetparam_id,
                                        :model<ComRate::Extractor::Schema::SheetParamSynonym>
                                    );

#    has UInt    $.sheetparameqn_id  is referencing(
#                                        *.id,
#                                        :model<ComRate::Extractor::Schema::SheetParamEqn>
#                                    );
#
#    has         $.equation          is relationship(
#                                        *.sheetparameqn_id,
#                                        :model<ComRate::Extractor::Schema::SheetParamEqn>
#                                    );
}
