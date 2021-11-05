use v6;
use Red;
use Data::Dump;

unit class ComRate::Extractor::RedWrap;

has $.prefix is rw;
has $.table is rw;

method set( Str $label ){
    my $table = $label;
    #my $prefix = %.conf<main><schema><module_prefix>;
    #say "prefix: $prefix";
    $table = $.prefix ~ '::' ~ $label if $.prefix;
    #my $table = "Schema::$label";
    require ::($table);

    $.table = $table;

    return self;
}

# method do( Str $label, Str $op, %params? ){
#
#     my %p = %params || ();
#     my $table = $label;
#     #my $prefix = %.conf<main><schema><module_prefix>;
#     #say "prefix: $prefix";
#     $table = $.prefix ~ '::' ~ $label if $.prefix;
#     #my $table = "Schema::$label";
#     require ::($table);
#
#     if $op eq 'search' {
#
#     } elsif $op eq 'find' {
#         say "params: " ~ Dump( %p );
#         my @rs = ::($table).^all.grep({ self.search( $_, %p ) });
#         return @rs[0];
#     } else {
#         my $resp = ::($table).HOW."$op"( ::($table), |%p );
#         return $resp;
#     }
# }

method search( %p = () ){
    say "p: " ~ Dump( %p );
    say "table: " ~ $.table;
    require ::($.table);
    my $rs = ::($.table).^all.grep({ self.match( $_, %p ) });
    return $rs;
}

method find( %p = () ){
    my $rs = self.search( %p );
    return $rs[0];
}

method find_or_create( %p = () ) {
    my $param_r = $.find( %p );
    $param_r = $.create( %p ) unless $param_r;
    return $param_r;
}

method match( $rec, %params ){
    my $match = True;
    for %params.kv -> $k, $v {
        if $rec."$k"() ne $v {
            $match = False;
            last;
        }
    }
    return $match;
}

method create( %p = () ){
    return self!do( 'create', %p );
}


method !do( $op, %p = () ){
    require ::($.table);
    my $resp = ::($.table).HOW."$op"( ::($.table), |%p );
    return $resp;
}
