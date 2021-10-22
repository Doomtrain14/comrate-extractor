use Red:api<2> <has-one>;

model Sheet {...};
model SheetSynonym {...};
model SheetParam {...};
model SheetParamSynonym {...};
model SheetParamEqn {...};
model SheetParamEqnComp {...};

model Sheet is rw {
    has UInt    $!id        is serial;
    has Str     $.name      is column{ :unique };
    has         @.synonyms  is relationship(
                                *.sheet_id,
                                :model<SheetSynonym>,
                                :require<ComRate::Extractor::Identifier::Schema>
                            );
    has         @.params    is relationship(
                                *.sheet_id,
                                :model<SheetParam>,
                                :require<ComRate::Extractor::Identifier::Schema>
                            );
}

model SheetSynonym is rw {
    has UInt    $!id            is serial;
    has Str     $.synonym       is column;
    has UInt    $.sheet_id      is referencing(
                                    *.id, 
                                    :model<Sheet>,
                                    :require<ComRate::Extractor::Identifier::Schema>
                                );
    has         $.sheet         is relationship(
                                    *.sheet_id, 
                                    :model<Sheet>
                                    :require<ComRate::Extractor::Identifier::Schema>
                                );  
}


model SheetParam is rw {
    has UInt    $!id                is serial;
    has UInt    $.sheet_id          is referencing(
                                        *.id, 
                                        :model<Sheet>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has Str     $.name              is column;
    has Str     $.sign              is column;
    has Int     $.collect           is column;
    has         $.sheet             is relationship(
                                        *.sheet_id, 
                                        :model<Sheet>
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );  
    has         @.synonyms          is relationship(
                                        *.sheetparam_id,
                                        :model<SheetParamSynonym>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has UInt    $.sheetparameqn_id  is referencing(
                                        *.id,
                                        :model<SheetParamEqn>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has         $.equation          is relationship(
                                        *.sheetparameqn_id,
                                        :model<SheetParamEqn>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
}

model SheetParamSynonym is rw {
    has UInt    $.id                is serial;
    has Str     $.synonym           is column;
    has UInt    $.sheetparam_id     is referencing(
                                        *.id, 
                                        :model<SheetParam>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has         $.sheetparam        is relationship(
                                        *.sheetparam_id, 
                                        :model<SheetParam>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );  
}

model SheetParamEqn is rw {
    has UInt    $!id                is serial;
    has Str     $.eqn_type          is column;
#    has Int     $.num_comps         is column;  # TODO: make computed
    has         @.components        is relationship(
                                        *.sheetparameqn_id,
                                        :model<SheetParamEqnComp>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
}

model SheetParamEqnComp is rw {
    has UInt    $!id                is serial;
    has UInt    $!sheetparameqn_id  is referencing(
                                        *.id, 
                                        :model<SheetParamEqn>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has UInt    $!sheetparam_id     is referencing(
                                        *.id,
                                        :model<SheetParam>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has         $.equation          is relationship(
                                        *.sheetparameqn_id,
                                        :model<SheetParamEqn>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
    has         $.param             is relationship(
                                        *.sheetparam_id,
                                        :model<SheetParam>,
                                        :require<ComRate::Extractor::Identifier::Schema>
                                    );
}

sub identifier_schema is export {
    $ = schema (Sheet, SheetSynonym, SheetParam, SheetParamSynonym, SheetParamEqn, SheetParamEqnComp);
}

