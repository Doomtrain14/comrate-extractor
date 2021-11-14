use v6;
use Red:ver<0.1.40>:api<2>;
#use ComRate::Extractor::RedWrap;
use YAML::Parser::LibYAML;
use Data::Dump;
use ComRate::Extractor::DBI;


class ComRate::Extractor::Essentials {

    has $!conf-dir = $*PROGRAM.IO.parent.parent.add('conf').resolve.Str;
    has $!conf-ext = 'yaml';
    has %.conf;
    has $.dbi = ComRate::Extractor::DBI.new;

    #has ComRate::Extractor::RedWrap $.red;

    method !init-conf {
        my %conf;

        for dir( $!conf-dir ) -> $path {
            my $ext = $path.extension;
            next unless $ext eq $!conf-ext;

            my $filename = $path.parts.tail<basename>;
            $filename ~~ s/ \. $ext $ //;
            my $conf = yaml-parse( $path.Str );
            %conf{ $filename } = $conf;
        }

        return %conf;
    }


    # method init-db{
    #     my %db = %.conf<main><database>;
    #     return database %db<type>, user => %db<user>, dbname => %db<name>, password => %db<password>;
    # }



    submethod TWEAK {
        %!conf = self!init-conf;
        # $!red = ComRate::Extractor::RedWrap.new(
        #     prefix => %!conf<main><schema><module_prefix>
        # );
    }




    # method search( $rec, %params ){
    #     my $match = True;
    #     for %params.kv -> $k, $v {
    #         if $rec."$k"() ne $v {
    #             $match = False;
    #             last;
    #         }
    #     }
    #     return $match;
    # }


    # method schema( Str $label, Str $op, %params? ){
    #
    #     my %p = %params || ();
    #     my $table = $label;
    #     my $prefix = %.conf<main><schema><module_prefix>;
    #     say "prefix: $prefix";
    #     $table = $prefix ~ '::' ~ $label if $prefix;
    #     #my $table = "Schema::$label";
    #     require ::($table);
    #
    #     if $op eq 'search' {
    #         my $rs = ::($table).^all.grep({ self.search( $_, %p ) });
    #         return $rs;
    #     } elsif $op eq 'find' {
    #         say "params: " ~ Dump( %p );
    #         my @rs = ::($table).^all.grep({ self.search( $_, %p ) });
    #         return @rs[0];
    #     } else {
    #         my $resp = ::($table).HOW."$op"( ::($table), |%p );
    #         return $resp;
    #     }
    # }

    method path( Str $dirname, *@frags ){
        #my @f = @frags || ();

        my $frag-dir = %.conf<main><dir>{ $dirname };
        my IO::Path $path;

        if $frag-dir.IO.is-absolute {
            $path = IO::Path.new( $frag-dir );
        } elsif %.conf<main><dir><base> {
            $path = IO::Path.new(%.conf<main><dir><base>.Str).add($frag-dir);
        } else {
            $path = $*PROGRAM.parent.parent.add($dirname);
        }

        for @frags -> $frag {
            $path.=add( $frag );
        }
        return $path;
    }
}
