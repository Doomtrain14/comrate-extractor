use v6;
use Red;
use YAML::Parser::LibYAML;
use Data::Dump;


class ComRate::Extractor::Essentials {

    has $!conf-dir = $*PROGRAM.IO.parent.parent.add('conf').resolve.Str;
    has $!conf-ext = 'yaml';

    has %.conf = sub {

        my %conf;

        for dir( $!conf-dir ) -> $path {
            say "file: " ~ $path.raku;
            my $ext = $path.extension;
            next unless $ext eq $!conf-ext;

            my $filename = $path.parts.tail<basename>;
            $filename ~~ s/ \. $ext $ //;
            say "filename: $filename\n";
            my $conf = yaml-parse( $path.Str );
            %conf{ $filename } = $conf;
        }

        return %conf;
    }();

    #my $*RED-DB = database "Pg", :user<vmail_user>, :dbname<vmail>, :password<efgdhc7TrDx>;

    method init-db{
        my %db = %.conf<main><database>;
        return database %db<type>, user => %db<user>, dbname => %db<name>, password => %db<password>;
    }


    method search( $rec, %params ){
        my $match = True;
        for %params.kv -> $k, $v {
            if $rec."$k"() ne $v {
                $match = False;
                last;
            }
        }
        return $match;
    }


    method schema( Str $label, Str $op, %params? ){

        my %p = %params || ();
        my $table = "Schema::$label";
        require ::($table);

        if $op eq 'search' {
            my $rs = ::($table).^all.grep({ self.search( $_, %p ) });
            return $rs;
        } else {
        #my $*RED-DB = database "Pg", :user<vmail_user>, :dbname<vmail>, :password<efgdhc7TrDx>;
            my $resp = ::($table).HOW."$op"( ::($table), |%p );
            return $resp;
        }
    }

    method path( Str $dirname, *@frags ){
        my @f = @frags || ();
        say "f: " ~ Dump( @f );
        say "frags: " ~ Dump( @frags );
		say "dirname: " ~ Dump( $dirname );

        my $frag-dir = %.conf<main><dir>{ $dirname };
		say "main: " ~ Dump( self.conf<main> );
		say "frag-dir: " ~ Dump( $frag-dir );

        my IO::Path $path;

        if $frag-dir.IO.is-absolute {
            $path = IO::Path.new( $frag-dir );
        } else {
            $path = IO::Path.new( %.conf<main><dir><base>.Str ).add( $frag-dir );
        }


        for @f -> $frag {
            $path.=add( $frag );
        }
        return $path;
    }
}