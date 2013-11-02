package MT::AssetFieldOptions::Util;

use strict;
use warnings;

use base qw(Exporter);
our @EXPORT = qw(plugin parse_options);

sub plugin {
    MT->component('AssetFieldOptions');
}

sub parse_options {
    my ( $str ) = @_;
    $str =~ s/(^\s+)|(\s+$)//g;
    my @tupples = split(/\s*;\s*/, $str || '');
    my %options;
    foreach my $t ( @tupples ) {
        my ( $name, $value ) = split( /\s*:\s*/, $t );
        $options{$name} = $value if defined $name and length($name);
    }

    \%options;
}

1;