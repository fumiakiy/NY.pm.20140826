use strict;
use warnings;

use Plack::Request;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new( $env );

    return sub {
        my $responder = shift;
        my $data = 'Hello SSE!';
        my $writer = $responder->(
            [ 200,
              [
                'Content-Type', 'text/plain',
                'Content-Length', length($data)
              ]
            ]
        );
        $writer->write($data);
    };
};


