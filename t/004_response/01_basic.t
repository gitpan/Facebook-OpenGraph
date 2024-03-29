use strict;
use warnings;
use Test::More;
use Facebook::OpenGraph::Response;

subtest 'initialize' => sub {
    my $res = Facebook::OpenGraph::Response->new;
    isa_ok($res, 'Facebook::OpenGraph::Response');
    isa_ok($res->json, 'JSON');
};

subtest 'accessor' => sub {
    my $headers = [
        'etag',
        '"a376a57cb3a4bd3a3c6a53fca06b0fd5badee50b"',
        'content-type',
        'text/javascript; charset=UTF-8',
        'pragma',
        'no-cache',
        'access-control-allow-origin',
        '*',
        'x-fb-rev',
        '1220390',
        'cache-control',
        'private, no-cache, no-store, must-revalidate',
        'expires',
        'Sat, 01 Jan 2000 00:00:00 GMT',
        'x-fb-debug',
        'oyi19Zu1f4q0fcjowQrrmu8Lby+AgrNcmfLfpMBWcuQ=',
        'date',
        'Thu, 24 Apr 2014 13:15:31 GMT',
        'connection',
        'keep-alive',
        'content-length',
        '185'
    ];
    my $req_headers = qq{GET /go.hagiwara HTTP/1.1\n}
                    . qq{Connection: keep-alive\n}
                    . qq{User-Agent: Facebook::OpenGraph/1.13\n}
                    . qq{Content-Length: 0\n}
                    . qq{Host: graph.facebook.com\n}
                    . qq{\n};
    my $content = '{"id":"12345"}';

    my $res = Facebook::OpenGraph::Response->new(+{
        code        => 200,
        message     => 'OK',
        headers     => $headers,
        req_headers => $req_headers,
        req_content => '',
        content     => $content,
    });

    is($res->code, 200);
    is($res->message, 'OK');
    is($res->req_headers, $req_headers);
    is($res->req_content, '');
    is($res->content, $content);
    is($res->etag, '"a376a57cb3a4bd3a3c6a53fca06b0fd5badee50b"');
    isa_ok($res->json, 'JSON');
    is_deeply($res->headers, $headers);
};

done_testing;
