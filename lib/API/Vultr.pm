package API::Vultr;

use 5.008;

use strict;
use warnings;

use Carp qw(croak);
use URI  qw();

our $VERSION = '0.001';

sub _make_uri {
    my ( $self, $path, %query ) = @_;

    my $uri = URI->new( 'https://api.vultr.com/v2' . $path );
    if (%query) {
        $uri->query_form(%query);
    }

    return $uri->as_string;
}

sub _request {
    my ( $self, $method, $uri, $body ) = @_;

    if ( not( defined $body ) ) {
        my $lc_method = lc $method;
        return $self->ua->$lc_method( $uri,
            Authorization => 'Bearer ' . $self->{api_key} );
    }
    else {
        my $request = HTTP::Request->new( uc $method, $uri );
        $request->header( 'Content-Type' => 'application/json' );
        $request->content($body);
        return $self->ua->request($request);
    }
}

sub api_key {
    my ( $self, $setter ) = @_;

    if ( defined $setter ) {
        return $self->{api_key} = $setter;
    }

    return $self->{api_key};
}

sub ua {
    my ( $self, $setter ) = @_;

    if ( defined $setter ) {
        return $self->{ua} = $setter;
    }

    return $self->{ua};
}

sub new {
    my ( $class, %args ) = @_;

    croak
      qq{You must specify an API key when creating an instance of API::Vultr}
      unless exists $args{api_key};

    my $self = { %args, ua => LWP::UserAgent->new( timeout => 10 ) };

    return bless( __PACKAGE__, $self );
}

sub list_instances {
    my ( $self, %query ) = @_;
    return $self->_request( 'get', $self->_make_uri( '/instances', %query ) );
}

sub create_instance {
    my ( $self, %body ) = @_;
    return $self->_request( 'post', $self->_make_uri('/instances'), {%body} );
}

sub get_instance_by_id {
    my ( $self, $id ) = @_;

    croak qq{ID cannot be undefined when calling get_instance_by_id.}
      unless defined $id;

    return $self->_request( 'get', $self->_make_uri( '/instances/' . $id ) );
}

sub delete_instance_by_id {
    my ( $self, $id ) = @_;

    croak qq{ID cannot be undefined when calling get_instance_by_id.}
      unless defined $id;

    return $self->_request( 'delete', $self->_make_uri( '/instances/' . $id ) );
}

sub halt_instances {
    my ( $self, @ids ) = @_;

    croak qq{Expected list of ids, instead got undef.}
      unless @ids;

    return $self->_request(
        'post',
        $self->_make_uri('/instances/halt'),
        { instance_ids => [@ids] }
    );
}

sub reboot_instances {
    my ( $self, @ids ) = @_;

    croak qq{Expected list of ids, instead got undef.}
      unless @ids;

    return $self->_request(
        'post',
        $self->_make_uri('/instances/reboot'),
        { instance_ids => [@ids] }
    );
}

sub start_instances {
    my ( $self, @ids ) = @_;

    croak qq{Expected list of ids, instead got undef.}
      unless @ids;

    return $self->_request(
        'post',
        $self->_make_uri('/instances/start'),
        { instance_ids => [@ids] }
    );
}

sub get_instance_bandwidth {
    my ( $self, $id, %query ) = @_;

    croak qq{Expected scalar id as second argument, instead got $id.}
      unless defined $id;

    return $self->_request( 'get',
        $self->_make_uri( '/instances/' . $id . '/bandwidth', %query ) );
}

sub get_instance_neighbours {
    my ( $self, $id ) = @_;

    croak qq{Expected scalar id as second argument, instead got $id.}
      unless defined $id;

    return $self->_request( 'get',
        $self->_make_uri( '/instances/' . $id . '/neighbours' ) );
}

sub get_instance_iso_status {
    my ( $self, $id ) = @_;

    croak qq{Expected scalar id as second argument, instead got $id.}
      unless defined $id;

    return $self->_request( 'get',
        $self->_make_uri( '/instances/' . $id . '/iso' ) );
}

sub detach_iso_from_instance {
    my ( $self, $id ) = @_;

    croak qq{Expected scalar id as second argument, instead got $id.}
      unless defined $id;

    return $self->_request( 'post',
        $self->_make_uri( '/instances/' . $id . '/iso/detach' ) );
}

sub attach_iso_to_instance {
    my ( $self, $id, $iso_id ) = @_;

    croak qq{Expected scalar id as second argument, instead got $id.}
      unless defined $id;

    croak qq{Expected scalar iso_id as second argument, instead got $iso_id.}
      unless defined $iso_id;

    return $self->_request(
        'post',
        $self->_make_uri( '/instances/' . $id . '/iso/attach' ),
        { iso_id => $iso_id }
    );
}

1;
