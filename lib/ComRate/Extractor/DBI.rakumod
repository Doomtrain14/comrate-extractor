use v6;
use DBIish;
use Data::Dump;

unit class ComRate::Extractor::DBI;

has $.table is rw;
has $.moniker is rw;
has $.dbh is rw;
has %!tables = (
  'Sheet' => 'sheet',
  'SheetParam' => 'sheet_param',
  'SheetParamEqn' => 'sheet_param_eqn',
  'SheetParamEqnComp' => 'sheet_param_eqn_comp'
);


method !init-dbh {
    $!dbh = DBIish.connect("Pg",
        :database<comrate_extractor>,
        :user<comrate_user>,
        :password<WgUiPWQsV9x>
    );
}

submethod TWEAK {
    self!init-dbh;
}



method set( Str $moniker ){
    $.table = %!tables{ $moniker };
    return self;
}


method !select( %params = %(), %config = %() ) {

    my $where-string = self!where-string( %params );

    my $sql = "SELECT * FROM $.table";

    if %config<join> {

        for %config<join>.kv -> $moniker, %terms {
            my $table = %.tables{ $moniker };
            $sql ~= " JOIN $table ON ";

            for %terms.kv -> $me_col, $you_col {
              $sql ~= $.table ~ '.' ~ $me_col ~ '=' ~ $table ~ '.' ~ $you_col;
            }
        }
    }

    if $where-string {
        $sql ~= " WHERE " ~ $where-string;
    }
    $sql ~= ';';

    say "SQL: $sql";
    my $sth = $!dbh.execute( $sql );

    return $sth;

}

method !where-string( %params ){
    my $where-string = '';

    for %params.kv -> $k, $v {
        $where-string ~= ' AND ' if $where-string;
        $where-string ~= "$k=";
        if $v.isa(Str) {
            $where-string ~= "'$v'";
        } elsif $v.isa(Num) or $v.isa(Int) {
            $where-string ~= $v.Str;
        } elsif $v.isa(Bool) {
            $where-string ~= $v ?? "true" !! "false";
        } else {
            die "param '$k': unsupported type (" ~ $v.WHAT ~ ")";
        }
    }

    return $where-string;
}




method find( %params ){
    my $sth = self!select( %params );
    my %row = $sth.row(:hash);
    return %row;
}

method search( %params, %config = %() ){

    my $sth = self!select( %params );
    my @all-rows = $sth.allrows(:array-of-hash);
    return @all-rows;
}

method find-or-create( %params ){
    my $sth = self!select( %params );
    my %row = $sth.row(:hash);
    return %row if %row;
    %row = self.create( %params );
    return %row;
}

method delete( %params = %() ){
    my $where-string = self!where-string( %params );
    my $sql = "DELETE FROM $.table";

    if $where-string {
      $sql~=' WHERE ' ~ $where-string;
    }

    $sql ~= ' RETURNING *;';

    my $sth = $!dbh.execute( $sql );
    my @all-rows = $sth.allrows(:array-of-hash);
    return @all-rows;
}



method create( %params ){


    my $k-string = '';
    my $v-string = '';

    say "creating: " ~ Dump( %params );

    for %params.kv -> $k, $v {
        $k-string ~= ', ' if $k-string;
        $k-string ~= $k;

        $v-string ~= ', ' if $v-string;
        if $v.isa(Str) {
            $v-string ~= "'$v'";
        } elsif $v.isa(Num) or $v.isa(Int) {
            $v-string ~= $v;
        } elsif $v.isa(Bool) {
            $v-string ~= $v ?? "true" !! "false";
        } else {
            die "param '$k': unsupported type (" ~ $v.WHAT ~ ")";
        }
    }

    my $sql = "INSERT INTO $.table ("
      ~ $k-string ~ ') VALUES ('
      ~ $v-string ~ ') RETURNING *;';

    my $sth = $!dbh.execute( $sql );
    #say "sth methods: " ~ $sth.^methods.gist;
    #say "dbh methods: " ~ $!dbh.^methods.gist;
    #say "insert id " ~ $sth.insert-id;
    #say "last-sth-id: " ~ $!dbh.last-sth-id;
    my %row = $sth.row(:hash);
    return %row;

}
