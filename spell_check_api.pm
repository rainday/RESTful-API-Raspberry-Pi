package spell_check_api;

use strict;
use Data::Dumper;
use Apache2::Const -compile => qw( :http OK AUTH_REQUIRED );
use Text::Aspell;
use CGI;
use JSON qw( to_json );

# authorization_basic
sub authen_handler {
    my ($o, $r) = @_;

    my ($res, $sent_pw) = $r->get_basic_auth_pw();
    return $res if ( $res != Apache2::Const::OK );

    my $user = $r->user();

    if ( authen_dbi($r, $user, $sent_pw) ) {
        $r->note_basic_auth_failure();
        return Apache2::Const::AUTH_REQUIRED;
    }

    return Apache2::Const::OK;
}

# User/Password check
sub authen_dbi {
    my ($r, $user, $sent_pw) = @_;

    # Could replace or add on db check
    my $auth_id = 'test123';
    my $auth_token = 'test123';

    if ( $auth_id ne $user || $auth_token ne $sent_pw ) {
        return 1;
    }

    return 0;
}

# GET request
# required parameter, word
# word could be single word or sentence
sub handler {
    my $r = shift;
    my $q = CGI->new();
    my $args = { map{ $_ => $q->param($_) } $q->param };
    # max number of returning suggested words
    my $max  = $args->{max} || 10;

    my $word = $args->{word};
    if ( $r->method eq 'GET' ) {
        my $SPELLER = check_setup( $args );
        
        $r->content_type('application/json');
        if ( $SPELLER->check( $word ) ) {
            # return correct:1 when the word is correct
            print '{"correct":"1"}';
        } elsif ( $word =~ /^[a-z0-9'".,]+\s+[a-z0-9'".,]+/i ) {
            # multiple words
            my $suggestions = multi_suggestion($SPELLER, $args);
            if ( !$suggestions ) {
                print '{"correct":"1"}';
            } else {
                my $json = to_json( $suggestions );
                print $json
            }
        } else {
            # single word suggestion
            my @suggestions = $SPELLER->suggest( $word );
            splice @suggestions, $max;
            my $json = to_json({ suggest=>{ $word=>\@suggestions } });
            # return json with suggest : word : [ suggestions ]
            print $json;
        }
        return Apache2::Const::OK;
    }

    return Apache2::Const::HTTP_METHOD_NOT_ALLOWED
}

# Text::Aspell setting
sub check_setup {
    my $SPELLER = Text::Aspell->new();
    my $args    = shift;
    my $max  = $args->{max} || 10;

    # Set some options
    $SPELLER->set_option('lang', 'en_US');
    $SPELLER->set_option('sug-mode', 'fast');

    return $SPELLER;
}

# for sentence or multiple words
sub multi_suggestion {
    my $SPELLER = shift;
    my $args    = shift;
    my $word    = $args->{word};
    my $max  = $args->{max} || 10;

    $word =~ s/\,|\.//g;
    my @words = split(/[\"\s+]/, $word);
    my $data = {};
    foreach my $w ( @words ) {
        next if ( $SPELLER->check( $w ) );
        my @suggestions = $SPELLER->suggest( $w );
        splice @suggestions, $max;
        $data->{suggest}->{$w} = \@suggestions;
    }

    # if there's no suggestions return 0 else return the suggestions
    return ( scalar( keys $data->{suggest}) ) ? $data : 0;
}

1;
