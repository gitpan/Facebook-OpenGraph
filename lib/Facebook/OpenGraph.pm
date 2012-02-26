use strict;
use warnings;
package Facebook::OpenGraph;

# ABSTRACT: Facebook OpenGraph API Wrapper

use JSON;
use Any::Moose;
use LWP::UserAgent;
use HTTP::Request::Common qw(GET POST DELETE);

our $VERSION = '0.1';

has base_url => (
	is			=> 'rw',
	required	=> 1,
	default		=> 'https://graph.facebook.com',
	isa			=> 'Str',
);

has app_id => (
	is			=> 'rw',
	required	=> 1,
	isa			=> 'Str',
);

has secret => (
	is			=> 'rw',
	required	=> 1,
	isa			=> 'Str',
);

has access_token => (
	is			=> 'rw',
	required	=> 1,
	isa			=> 'Str',
);

has user_agent => (
	is			=> 'rw',
	lazy		=> 1,	
	required	=> 1,
	isa			=> 'LWP::UserAgent',
	default		=> sub {
		LWP::UserAgent->new(
			agent => __PACKAGE__.'/'.$VERSION
		);
	},
);

sub BUILD {
	## graph.facebook.com doesn't like default LWP headers
	push @LWP::Protocol::http::EXTRA_SOCK_OPTS, SendTE => 0;
}

sub get {
	my $self = shift;
	my $action = shift;
	my $params = shift || {};

	$params->{access_token} = $self->access_token;

	my $uri = URI->new(join '/',$self->base_url,'me',$action);
	$uri->query_form(%$params);

	my $res = $self->user_agent->request(
		GET $uri->as_string
	);

	if ($res->is_success) {
		return decode_json($res->decoded_content);
	} else {
		confess $res->status_line;
	}
}

sub post {
	my $self = shift;
	my $action = shift;

	my $params = shift || {};
	$params->{access_token} = $self->access_token;

	my $uri = URI->new(join '/',$self->base_url,'me',$action);
	$uri->query_form(%$params);

	my $res = $self->user_agent->request(
		POST $uri->as_string
	);

	if (my $content = $res->decoded_content) {
		return decode_json($res->decoded_content);
	} else {
		confess $res->status_line;
	}
}


sub delete {
	my $self = shift;
	my $action_id = shift;

	my $params = shift || {};
	$params->{access_token} = $self->access_token;

	my $uri = URI->new(join '/',$self->base_url,$action_id);
	$uri->query_form(%$params);

	my $res = $self->user_agent->request(
		DELETE $uri->as_string
	);

	if (my $content = $res->decoded_content) {
		return decode_json($res->decoded_content);
	} else {
		confess $res->status_line;
	}
}

1;



__END__
=pod

=head1 NAME

Facebook::OpenGraph - Facebook OpenGraph API Wrapper

=head1 VERSION

version 0.1

=head1 SYNOPSIS

	use Facebook::OpenGraph;

	my $fbog = Facebook::OpenGraph->new({
		app_id => '..',
		secret => '..',
		access_token => '...',
	});

	$fbog->post('video.watches',{
		movie => 'http://www.example.com/movie.html'
	});

	my $res = $fbog->get('video.watches',{
		offset	=> 0,
		limit	=> 25,
	});

	foreach my $action (@{$res->{data}}) {
		$fbog->delete($action->{id});
	}

=head1 DESCRIPTION

This distribution provides a wrapper around the Facebook OpenGraph API:

L<http://developers.facebook.com/docs/opengraph/>

=head1 METHODS

=head2 $fbog->get($action, \%params);

Get existing actions:

	{
		'paging' => {
			'next' => 'https://graph.facebook.com/me/video.watches?access_token=...&offset=25&limit=25'
		},
		'data' => [
			{
				'id' => '137465449710258',
				'application' => {
					'name' => 'Cinemoz (dev)',
					'id' => '...'
				},
				'start_time' => '0000-00-00T00:00:00+0000',
				'publish_time' => '0000-00-00T00:00:00+0000',
				'end_time' => '0000-00-00T00:00:00+0000',
				'data' => {
					'movie' => {
						'url' => 'http://example.com/movie.html',
						'title' => 'Example Movie',
						'type' => 'video.movie',
						'id' => '...'
					}
				},
				'comments' => {
					'count' => 0
				},
				'from' => {
					'name' => 'Sandra Amcdigegjhcd Laustein',
					'id' => '100003497570834'
				},
				'likes' => {
					'count' => 0
				}
			}
		]
	}

=head2 $fbog->post($action, \%params);

Post a new action:

	{
		'id' => '...'
	}

=head2 $fbog->delete($action_id);

Delete an action

=head1 SEE ALSO

L<Facebook::Graph>

=head1 AUTHOR

Maroun NAJM <mnajm@cinemoz.com>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Cinemoz.

This is free software, licensed under:

  The (three-clause) BSD License

=cut

