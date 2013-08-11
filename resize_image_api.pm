package resize_image_api;

use strict;
use Data::Dumper;
use Apache2::Const -compile => qw( :http OK AUTH_REQUIRED );
use CGI;
use JSON qw( decode_json to_json );
use LWP::UserAgent;
use LWP::Simple;
use File::MMagic;
use Image::Magick;

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

# User/Password Check
sub authen_dbi {
    my ($r, $user, $sent_pw) = @_;

    my $auth_id = 'test123';
    my $auth_token = 'test123';

    if ( $auth_id ne $user || $auth_token ne $sent_pw ) {
        return 1;
    }

    return 0;
}

# POST Request, accept JSON
# require parameters, image_url, height or width
# extra paramters could look up Image::Magick Scale
sub handler {
    my $r = shift;
    my $q = CGI->new();
    my $args = { map{ $_ => $q->param($_) } $q->param };

    return Apache2::Const::HTTP_METHOD_NOT_ALLOWED if ( $r->method ne 'POST' );

    my $params = decode_json($args->{POSTDATA});

    # require original image url, height or width that want's do be resized
    if ( $params->{image_url} && ($params->{height} || $params->{width}) ) {
        # Using LWP::UserAgent and File::MMagic to check content type to make sure it's an image
        my $ua = LWP::UserAgent->new();
        my $res = $ua->get($params->{image_url});
        my $fm = File::MMagic->new();
        # Only resize when it's jpeg, gif, png
        if ( $fm->checktype_contents($res->content) =~ /image\/(jpeg|gif|png)/ ) {
            # Create a unique file name ip_time
            my $type = $1;
            my $file_name = $ENV{REMOTE_ADDR};
            $file_name =~ s/\.|\://g;
            $file_name .= '_' . time() . ".$type";

            # Use LWP::Simple to save the original image 
            getstore($params->{image_url}, "/tmp/org_$file_name");

            # Use Image::<agick Do the resize
            my $im = Image::Magick->new();
            my $file = "/tmp/org_$file_name";
            $im->read($file);

            # This way user could pass in any args that Scale could accept
            # If we want to limit the options could put it in to a hash first
            # Basic Pass in width and height
            $im->Scale(%$params);
            $im->Write( "/tmp/$file_name" );
            $r->content_type('application/json');
            my $new_image_url = $ENV{HTTP_HOST} . "/images/$file_name";
            my $org_image_url = $ENV{HTTP_HOST} . "/images/org_$file_name";
            my $re_args = {
                orignal => $org_image_url,
                new     => $new_image_url,
            };
            print to_json( $re_args );
            return Apache2::Const::OK;
        }

        return Apache2::Const::HTTP_UNSUPPORTED_MEDIA_TYPE;
    } else {
        # respond missing params
        my $re_text = 'Missing parameter: ';
        foreach my $m ( qw/image_url height_width/ ) {
            if ( $m eq 'height_width' ) {
                $re_text .= "height/width " if ( !$params->{height} && !$params->{width} );
            } elsif ( !$params->{$m} ) {
                $re_text .= "$m ";
            }
        }
        
        $r->custom_response(Apache2::Const::HTTP_BAD_REQUEST, $re_text);
        return Apache2::Const::HTTP_BAD_REQUEST;
    }

}

1;
