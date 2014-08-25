use strict;
use warnings;

use Plack::Request;
use HTTP::ServerEvent;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new( $env );

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
        my $hse = HTTP::ServerEvent->as_string(
            data => $data
        );
        $writer->write($hse);
    };
};


