#line 1
package Test::Mock::Furl;
use strict;
use warnings;
use Test::MockObject;
use parent 'Exporter';
our @EXPORT = qw/
    $Mock_furl
    $Mock_furl_http
    $Mock_furl_req $Mock_furl_request
    $Mock_furl_res $Mock_furl_resp $Mock_furl_response
/;

our $VERSION = '0.04';

BEGIN {
    # Don't load the mock classes if the real ones are already loaded
    my $mo = Test::MockObject->new;
    my @mock_classes = (
        [ 'Furl'     => '$Mock_furl' ],
        [ 'HTTP'     => '$Mock_furl_http' ],
        [ 'Request'  => '$Mock_furl_request $Mock_furl_req' ],
        [ 'Response' => '$Mock_furl_response $Mock_furl_resp $Mock_furl_res' ],
    );
    for my $c (@mock_classes) {
        my ($real, $imports) = @$c;
        if (!$mo->check_class_loaded($real)) {
            my $mock_class = "Test::Mock::Furl::$real";
            eval "require $mock_class"; ## no critic
            if ($@) {
                warn "error during require $mock_class: $@" if $@;
                next;
            }
            my $import = "$mock_class qw($imports)";
            eval "import $import"; ## no critic
            warn "error during import $import: $@" if $@;
        }
    }
}

1;

__END__

#line 123


#line 153
