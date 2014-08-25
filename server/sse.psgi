use strict;
use warnings;

use Plack::Request;
use HTTP::ServerEvent;
use AnyEvent;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new( $env );
    my $w;

    return sub {
        my $responder = shift;
        my $data = 'Hello SSE!';
        my $writer = $responder->(
            [ 200,
              [
                'Content-Type', 'text/event-stream',
              ]
            ]
        );
        open my $fh, '<', '/tmp/sse';
        $w = AnyEvent->io(
            fh => $fh
            , poll => 'r'
            , cb => sub {
                my $data = <$fh>;
                $data or return;
                chomp $data;
                my $hse = HTTP::ServerEvent->as_string(
                    data => $data
                );
                $writer->write($hse);
                if ( $data eq 'bye' ) {
                    close $fh;
                    undef $w;
                }
            }
        );
    };
};


