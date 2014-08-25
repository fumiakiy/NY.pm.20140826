use strict;
use warnings;

use Plack::Request;
use HTTP::ServerEvent;
use AnyEvent;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new( $env );
    my $w;

    my @data = (0..100);
    return sub {
        my $responder = shift;
        my $data = 'Hello SSE!';
        my $writer = $responder->(
            [ 200,
              [
                'Content-Type', 'text/event-stream',
                'Access-Control-Allow-Origin', '*',
              ]
            ]
        );
        my $i = 0;
        my $last_event_id = $req->header('last-event-id');
        $last_event_id and $i += $last_event_id + 1;
        while ( $last_event_id + 1 ) {
            shift @data;
            $last_event_id--;
        }
        $w = AnyEvent->timer(
            after => 0
            , interval => 2
            , cb => sub {
                my $hse = HTTP::ServerEvent->as_string(
                    id => $i++
                    , event => 'data'
                    , data => shift(@data)
                );
                $writer->write($hse);
                unless ( @data ) {
                    $hse = HTTP::ServerEvent->as_string(
                        event => 'closed'
                        , data => $data
                    );
                    $writer->write($hse);
                    undef $w;
                }
            }
        );
    };
};


