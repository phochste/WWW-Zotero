package WWW::Zotero::Write;
use strict;
use warnings;
use parent "WWW::Zotero";
use Carp;
use JSON;
use POSIX qw(strftime);
use Data::Dumper;

=head1 NAME

WWW::Zotero::Write - Perl interface to the Zotero Write API

=cut

=head2 addCollections()

Add an array of collection 
Param: the array ref of hash ref with collection name and parent key 
[{"name"=>"coll name", "parentCollection"=> "parent key"}, {}]
Param: the group id
Returns undef if the ResponseCode is not 200 (409: Conflit, 412: Precondition failed)
Returns an array with three hash ref (or undef if the hash are empty): changed, unchanged, failed. 
The keys are the index of the hash received in argument. The values are the keys given by zotero

=cut

sub addCollections {
    my ( $self, $coll, $groupid ) = @_;
    my $url = $self->baseurl() . "/groups/$groupid/collections";
    croak "addCollections: can't treat more then 25 elements"
        if ( scalar @$coll > 25 );
    croak "addCollections: need a group id" unless ($groupid);
    my $token = encode_json($coll);

    $self->log->debug( $url . " " . $token );
    my $response = $self->client->POST( $url, $token );


    return $self->_check_response( $response, "200" );
}

=head2 addItems($items, $groupid)

Add an array of items 
Param: the array ref of hash ref with completed item templates 
Param: the group id
Returns undef if the ResponseCode is not 200 (see https://www.zotero.org/support/dev/web_api/v3/write_requests)
Returns an array with three hash ref (or undef if the hash are empty): changed, unchanged, failed. 
The keys are the index of the hash received in argument. The values are the keys given by zotero

=cut

sub addItems {
    my ( $self, $items, $groupid ) = @_;
    my $url = $self->baseurl() . "/groups/$groupid/items";
    croak "addItems: can't treat more then 25 elements"
        if ( scalar @$items > 25 );
    croak "addItems: need a group id" unless ($groupid);

    #die $items->[0];
    my $token = encode_json($items);
    my $response = $self->client->POST( $url, $token );
    return $self->_check_response( $response, "200" );

}

=head2 updateItems($data, $groupid)

Update an array of items
Param: the array ref of hash ref which must include the key of the item, the version of the item and the new value
Param: the group id
Returns undef if the ResponseCode is not 200 (see https://www.zotero.org/support/dev/web_api/v3/write_requests)
Returns an array with three hash ref (or undef if the hash are empty): changed, unchanged, failed. 
The keys are the index of the hash received in argument. The values are the keys given by zotero

=cut

sub updateItems {
    my ( $self, $data, $groupid ) = @_;
    croak "updateItems: can't treat more then 50 elements"
        if ( scalar @$data > 50 );
    croak "updateItems: need a group id" unless ($groupid);
    my $url = $self->baseurl() . "/groups/$groupid/items";
    my $token = encode_json($data);
    my $response = $self->client->POST( $url, $token );
    return $self->_check_response( $response, "200" );
}

=head2 deleteItems($keys, $groupid)

Delete an array of items
Param: the array ref of item's key to delete
Param: the group id
Returns undef if the ResponseCode is not 204 (see https://www.zotero.org/support/dev/web_api/v3/write_requests)

=cut

sub deleteItems {
    my ( $self, $keys, $groupid ) = @_;
    croak "deleteItems: can't treat more then 50 elements"
        if ( scalar @$keys > 50 );
    croak "deleteItems: need a group id" unless ($groupid);
    my $url =
          $self->baseurl()
        . "/groups/$groupid/items?itemKey="
        . join( ",", @$keys );

    #ensure to set the last-modified-version with querying
    #all the top collection
    $self->listCollectionsTop( group => $groupid );
    $self->client->addHeader( 'If-Unmodified-Since-Version',
        $self->last_modif_ver() );
    my $response = $self->client->DELETE($url);
    return $self->_check_response( $response, "204" );

}

=head2 deleteCollections($keys, $groupid)

Delete an array of items
Param: the array ref of item's key to delete
Param: the group id
Returns undef if the ResponseCode is not 204 (see https://www.zotero.org/support/dev/web_api/v3/write_requests)

=cut

sub deleteCollections {
    my ( $self, $keys, $groupid ) = @_;
    croak "deleteCollections: can't treat more then 50 elements"
        if ( scalar @$keys > 50 );
    croak "deleteCollections: need a group id" unless ($groupid);
    my $url =
          $self->baseurl()
        . "/groups/$groupid/collections?collectionKey="
        . join( ",", @$keys );

    #ensure to set the last-modified-version with querying
    #all the top collection
    $self->listCollectionsTop( group => $groupid );
    my $ver = $self->last_modif_ver();

    $self->client->addHeader( 'If-Unmodified-Since-Version', $ver );

    $self->log->debug( "> Version send: ", $ver );
    my $response = $self->client->DELETE($url);
    return $self->_check_response( $response, "204" );

}

sub _check_response {
    my ( $self, $response, $success_code ) = @_;
    my $code = $response->responseCode;
    my $res  = $response->responseContent;
    $self->log->debug( "> Code: ",    $code );
    $self->log->debug( "> Content: ", $res );

    return unless ( $code eq $success_code );
    if ( $success_code eq "200" ) {
        my $data = decode_json($res);
        my @results;
        for my $href ( $data->{success}, $data->{unchanged}, $data->{failed} )
        {
            push @results, ( scalar keys %$href > 0 ? $href : undef );
        }
        return @results;
    }
    else { return 1 }
    ;    #code 204

}

1;

