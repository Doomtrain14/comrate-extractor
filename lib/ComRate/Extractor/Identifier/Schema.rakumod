use Red:api<2> <has-one>;

model Sheet is rw {
    has UInt    $!id        is serial;
    has Str     $.name      is column{ :unique };
    has         @.synonyms  is relationship(
                                *.SheetSynonym_id,
                                :model<SheetSynonym>,
                                :require<ComRate::Extractor::Identifier::Schema>
                            );
    has         @.params    is relationship(
                                *.SheetParam_id,
                                :model<SheetParam>,
                                :require<ComRate::Extractor::Identifier::Schema>
                            );
}

model SheetSynonym is rw {
    has UInt    $!id            is serial;
    has Str     $.synonym       is column;
    has UInt    $!Sheet_id      is referencing(
                                    *.id, 
                                    :model<Sheet>,
                                    :require<ComRate::Extractor::Identifier::Schema>
                                );
}

model SheetParam is rw {
    has UInt    $!id            is serial;
    has UInt    $!Sheet_id      is referencing(
                                    *.id, 
                                    :model<Sheet>,
                                    :require<ComRate::Extractor::Identifier::Schema>
                                );
    has Str     $.name          is column;
    has         $.eqn           is relationship(
                                    *.SheetParamEqn_id, 
                                    :model<SheetParamEqn>, 
                                    :require<ComRate::Extractor::Identifier::Schema>,
                                    :has-one
                                );
}

model SheetParamEqn is rw {
    has UInt    $!id                is serial;
    has UInt    $!SheetParam_id     is referencing(
                                        *.id,
                                        :model<SheetParam>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has Str     $.eqn_type          is column;
    has Int     $.num_comps         is column;  # TODO: make computed
    has         @.comps             is relationship(
                                        *.SheetParamEqnComp,
                                        :model<SheetParamEqnComp>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
}

model SheetParamEqnComp is rw {
    has UInt    $!id                is serial;
    has UInt    $!SheetParamEqn_id  is referencing(
                                        *.id, 
                                        :model<SheetParamEqn>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has UInt    $!SheetParam_id     is referencing(
                                        *.id,
                                        :model<SheetParam>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
}

sub identifier_schema is export {
    $ = schema (Sheet, SheetSynonym, SheetParam, SheetParamEqn, SheetParamEqnComp);
}

