use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Mock::Furl;
use Facebook::OpenGraph;

subtest 'success' => sub {

    my $code    = 'XXXXXXXXXXXXXXXXXXXXXX';
    my $app_id  = 123456789;
    my $token   = '123456789XXXXXXXXXXX';
    my $expires = 5183814;

    $Mock_furl_http->mock(
        request => sub {
            my ($mock, %args) = @_;
            is_deeply $args{headers}, [], 'no particular header';
            my $uri = $args{url};
            is $uri->scheme, 'https', 'scheme';
            is $uri->host, 'graph.facebook.com', 'host';
            is $uri->path, '/oauth/access_token', 'path';
            is_deeply(
                +{
                    $uri->query_form,
                },
                +{
                    client_secret => 'secret',
                    client_id     => $app_id,
                    code          => $code,
                    redirect_uri  => 'http://sample.com/auth_cb',
                },
                'query',
            );
            is $args{method}, 'GET', 'HTTP GET method';
            is $args{content}, '', 'content';
    
            return (
                1,
                200,
                'OK',
                ['Content-Type' => 'text/plain; charset=UTF-8'],
                sprintf('access_token=%s&expires=%d', $token, $expires),
            );
        },
    );

    # Redirect_uri should be exactly the same as the one
    # that you used on $fb->auth_uri
    my $fb = Facebook::OpenGraph->new(+{
        app_id       => $app_id,
        secret       => 'secret',
        redirect_uri => 'http://sample.com/auth_cb',
    });
    my $token_ref = $fb->get_user_token_by_code($code);

    is_deeply(
        $token_ref,
        +{
            access_token => $token,
            expires      => $expires,
        },
        'token',
    );
    is $fb->access_token, undef, 'no access_token is set';
    $fb->set_access_token($token_ref->{access_token});        
    is $fb->access_token, $token, 'acess token is set';

};

done_testing;
