package MT::AssetFieldOptions::App;

use strict;
use warnings;

use MT::Util;
use MT::AssetFieldOptions::Util;

sub customfield_types {
    my $image_field = MT->component('Commercial')->registry('customfield_types', 'image');

    my $field_html_params = $image_field->{field_html_params};

    $image_field->{field_html} = q{
        <mt:include name="asset-chooser.tmpl">
        <mt:unless name="simple">
            <mt:if name="options_hints">
            <ul class="hint">
                <mt:loop name="options_hints">
                <li class="icon-left icon-warning"><mt:var name="__value__"></li>
                </mt:loop>
            </ul>
            </mt:if>
        </mt:unless>
    };
    $image_field->{field_html_params} = sub {
        my ( $key, $tmpl_key, $tmpl_param ) = @_;
        my @hints;

        if ( $tmpl_key eq 'field_html' ) {
            my $options = parse_options($tmpl_param->{options});

            if ( my $size = $options->{size} ) {
                if ( $size =~ /([0-9]+)\s*x\s*([0-9]+)/ ) {
                    my ( $width, $height ) = ( $1, $2 );
                    push @hints, plugin->translate( 'Size must be [_1]x[_2] pixels.', $width, $height );
                }
            }
        } else {
            push @hints, plugin->translate('Please enter size: WxH; (ex: size: 320x240;) if you want to fix size for an image.');
        }

        $tmpl_param->{options_hints} = \@hints if @hints;
        $field_html_params->(@_);
    };
    $image_field->{options_field} = q{
        <__trans_section component="AssetFieldOptions">
        <input type="text" name="options" value="<mt:var name="options" escape="html">" id="options" class="text" />
        <mt:if name="options_hints">
            <ul class="hint">
                <mt:loop name="options_hints">
                <li class="icon-left icon-related"><mt:var name="__value__"></li>
                </mt:loop>
            </ul>
        </mt:if>
        </__trans_section>
    };

    {};
}

sub app_pre_listing_list_asset {
    my ( $cb, $app, $terms, $args, $param, $rhasher ) = @_;
    my $q = $app->param;
    my $blog = $app->blog or return 1;

    my $edit_field = $q->param('edit_field');
    my ( $basename ) = $edit_field =~ /^customfield_(.+)$/;
    return 1 unless $basename;

    my $field = MT->model('field')->load({
        blog_id => [ $blog->id, 0 ],
        basename => $basename,
    }) or return 1;

    # FIXME Skip if not a hash terms
    return 1 if ref $terms ne 'HASH';

    my $options = parse_options($field->options);
    if ( $field->type eq 'image' ) {
        if ( my $size = $options->{size} ) {
            if ( $size =~ /([0-9]+)\s*x\s*([0-9]+)/ ) {
                my ( $width, $height ) = ( $1, $2 );

                # Match to width
                my @match_ids;
                my %args = %$args;
                $args{joins} ||= [];
                push @{ $args{joins} }, MT->model('asset')->meta_pkg->join_on(
                    undef,
                    {
                        type => 'image_width',
                        asset_id => \"= asset_id", # FOR-EDITOR ",
                        vinteger => $width,
                    }
                );
                if ( my $iter = MT->model('asset')->load_iter($terms, \%args) ) {
                    while ( my $asset = $iter->() ) {
                        push @match_ids, $asset->id;
                    }
                }

                # Match to height
                $terms->{id} = \@match_ids;
                $args->{joins} ||= [];
                push @{ $args->{joins} }, MT->model('asset')->meta_pkg->join_on(
                    undef,
                    {
                        type => 'image_height',
                        asset_id => \"= asset_id", # FOR-EDITOR ",
                        vinteger => $height,
                    }
                );

                ## Can't joins two meta tables?
                # $args->{joins} ||= [];
                # push @{ $args->{joins} },
                #     MT->model('asset')->meta_pkg->join_on(
                #         undef,
                #         {   type     => 'image_width',
                #             asset_id => \"= asset_id",      # FOR-EDITOR ",
                #             vinteger => $width,
                #         },
                #     ), MT->model('asset')->meta_pkg->join_on(
                #         undef,
                #         {   type     => 'image_height',
                #             asset_id => \"= asset_id",      # FOR-EDITOR ",
                #             vinteger => $height,
                #         },
                #     );
            }
        }
    }

    1;
}

sub cms_pre_save_asset {
    my ( $cb, $app, $asset, $original ) = @_;

    my $q = $app->param;
    my $blog = $app->blog or return 1;

    my $edit_field = $q->param('edit_field');
    my ( $basename ) = $edit_field =~ /^customfield_(.+)$/;
    return 1 unless $basename;

    my $field = MT->model('field')->load({
        blog_id => [ $blog->id, 0 ],
        basename => $basename,
    }) or return 1;

    my $options = parse_options($field->options);
    if ( $field->type eq 'image' ) {
        if ( my $size = $options->{size} ) {
            if ( $size =~ /([0-9]+)\s*x\s*([0-9]+)/ ) {
                my ( $width, $height ) = ( $1, $2 );
                return $app->error( plugin->translate('Image is not match [_1]x[_2] pixels.', $width, $height) )
                    if $asset->image_width != $width or $asset->image_height != $height;
            }
        }
    }

    1;
}

1;