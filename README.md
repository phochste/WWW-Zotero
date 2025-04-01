We migrated to https://codeberg.org/phochste/WWW-Zotero

# NAME

WWW::Zotero - Perl interface to the Zotero API

# SYNOPSIS

    use WWW::Zotero;

    my $client = WWW::Zotero->new;
    my $client = WWW::Zotero->new(key => 'API-KEY');

    my $data = $client->itemTypes();

    for my $item (@$data) {
        print "%s\n" , $item->itemType;
    }

    my $data   = $client->itemFields();
    my $data   = $client->itemTypeFields('book');
    my $data   = $client->itemTypeCreatorTypes('book');
    my $data   = $client->creatorFields();
    my $data   = $client->itemTemplate('book');
    my $key    = $client->keyPermissions();
    my $groups = $client->userGroups($userID);

    my $data   = $client->listItems(user => '475425', limit => 5);
    my $data   = $client->listItems(user => '475425', format => 'atom');
    my $generator = $client->listItems(user => '475425', generator => 1);

    while (my $item = $generator->()) {
        print "%s\n" , $item->{title};
    }

    my $data = $client->listItemsTop(user => '475425', limit => 5);
    my $data = $client->listItemsTrash(user => '475425');
    my $data = $client->getItem(user => '475425', itemKey => 'TTJFTW87');
    my $data = $client->getItemTags(user => '475425', itemKey => 'X42A7DEE');
    my $data = $client->listTags(user => '475425');
    my $data = $client->listTags(user => '475425', tag => 'Biography');
    my $data = $client->listCollections(user => '475425');
    my $data = $client->listCollectionsTop(user => '475425');
    my $data = $client->getCollection(user => '475425', collectionKey => 'A5G9W6AX');
    my $data = $client->listSubCollections(user => '475425', collectionKey => 'QM6T3KHX');
    my $data = $client->listCollectionItems(user => '475425', collectionKey => 'QM6T3KHX');
    my $data = $client->listCollectionItemsTop(user => '475425', collectionKey => 'QM6T3KHX');
    my $data = $client->listCollectionItemsTags(user => '475425', collectionKey => 'QM6T3KHX');
    my $data = $client->listSearches(user => '475425');

# CONFIGURATION

- baseurl

    The base URL for all API requests. Default 'https://api.zotero.org'.

- version

    The API version. Default '3'.

- key

    The API key which can be requested via https://api.zotero.org.

- modified\_since

    Include a UNIX time to be used in a If-Modified-Since header to allow for caching
    of results by your application.

# METHODS

## username2userID

Find the userID based on a username

## itemTypes()

Get all item types. Returns a Perl array.

## itemTypes()

Get all item fields. Returns a Perl array.

## itemTypes($type)

Get all valid fields for an item type. Returns a Perl array.

## itemTypeCreatorTypes($type)

Get valid creator types for an item type. Returns a Perl array.

## creatorFields()

Get localized creator fields. Returns a Perl array.

## itemTemplate($type)

Get a template for a new item. Returns a Perl hash.

## keyPermissions($key)

Return the userID and premissions for the given API key.

## userGroups($userID)

Return an array of the set of groups the current API key as access to.

## listItems(user => $userID, %options)

## listItems(group => $groupID, %options)

List all items for a user or ar group. Optionally provide a list of options:

    sort      - dateAdded, dateModified, title, creator, type, date, publisher,
           publicationTitle, journalAbbreviation, language, accessDate,
           libraryCatalog, callNumber, rights, addedBy, numItems (default dateModified)
    direction - asc, desc
    limit     - integer 1-100* (default 25)
    start     - integer
    format    - perl, atom, bib, json, keys, versions , bibtex , bookmarks,
                coins, csljson, mods, refer, rdf_bibliontology , rdf_dc ,
                rdf_zotero, ris , tei , wikipedia (default perl)

    when format => 'json'

        include   - bib, data

    when format => 'atom'

        content   - bib, html, json

    when format => 'bib' or content => 'bib'

        style     - chicago-note-bibliography, apa, ...  (see: https://www.zotero.org/styles/)


    itemKey    - A comma-separated list of item keys. Valid only for item requests. Up to
                 50 items can be specified in a single request.
    itemType   - Item type search
    q          - quick search
    qmode      - titleCreatorYear, everything
    since      - integer
    tag        - Tag search

See: https://www.zotero.org/support/dev/web\_api/v3/basics#user\_and\_group\_library\_urls
for the search syntax.

Returns a Perl HASH containing the total number of hits plus the results:

    {
        total => '132',
        results => <data>
    }

## listItems(user => $userID | group => $groupID, generator => 1 , %options)

Same as listItems but this return a generator for every record found. Use this
method to sequentially read the complete resultset. E.g.

    my $generator = $self->listItems(user => '231231', generator);

    while (my $record = $generator->()) {
        printf "%s\n" , $record->{title};
    }

The format is implicit 'perl' in this case.

## listItemsTop(user => $userID | group => $groupID, %options)

The set of all top-level items in the library, excluding trashed items.

See 'listItems(...)' functions above for all the execution options.

## listItemsTrash(user => $userID | group => $groupID, %options)

The set of items in the trash.

See 'listItems(...)' functions above for all the execution options.

## getItem(itemKey => ... , user => $userID | group => $groupID, %options)

A specific item in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the item if found.

## getItemChildren(itemKey => ... , user => $userID | group => $groupID, %options)

The set of all child items under a specific item.

See 'listItems(...)' functions above for all the execution options.

Returns the children if found.

## getItemTags(itemKey => ... , user => $userID | group => $groupID, %options)

The set of all tags associated with a specific item.

See 'listItems(...)' functions above for all the execution options.

Returns the tags if found.

## listTags(user => $userID | group => $groupID, \[tag => $name\] , %options)

The set of tags (i.e., of all types) matching a specific name.

See 'listItems(...)' functions above for all the execution options.

Returns the list of tags.

## listCollections(user => $userID | group => $groupID , %options)

The set of all collections in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the list of collections.

## listCollectionsTop(user => $userID | group => $groupID , %options)

The set of all top-level collections in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the list of collections.

## getCollection(collectionKey => ... , user => $userID | group => $groupID, %options)

A specific item in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the collection if found.

## listSubCollections(collectionKey => ...., user => $userID | group => $groupID , %options)

The set of subcollections within a specific collection in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the list of (sub)collections.

## listCollectionItems(collectionKey => ...., user => $userID | group => $groupID , %options)

The set of all items within a specific collection in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the list of items.

## listCollectionItemsTop(collectionKey => ...., user => $userID | group => $groupID , %options)

The set of top-level items within a specific collection in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the list of items.

## listCollectionItemsTags(collectionKey => ...., user => $userID | group => $groupID , %options)

The set of tags within a specific collection in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the list of items.

## listSearches(user => $userID | group => $groupID , %options)

The set of all saved searches in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the list of saved searches.

## getSearch(searchKey => ... , user => $userID | group => $groupID, %options)

A specific saved search in the library.

See 'listItems(...)' functions above for all the execution options.

Returns the saved search if found.

# AUTHOR

Patrick Hochstenbach, `<patrick.hochstenbach at ugent.be>`

# CONTRIBUTORS

François Rappaz

# LICENSE AND COPYRIGHT

Copyright 2015 Patrick Hochstenbach

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
