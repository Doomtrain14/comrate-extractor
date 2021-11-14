use DB::Xoos::Model;

unit class ComRate::Extractor::Model::Sheet does DB::Xoos::Model['sheet'];

has @.columns = [
    id => {
        type => 'integer',
        nullable => False,
        is-primary-key => True,
        auto-increment => 1
    },
    name => {
        type => 'text'
    }
];

#has @.relations = [
#    params => {
#        :has-many,
#        :model<ComRate::Extractor::Schema::SheetParam>,
#        :relate(id => 'sheet_id')
#    },
#];
