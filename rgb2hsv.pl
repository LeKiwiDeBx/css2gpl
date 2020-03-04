#!/usr/bin/perl -w -s
## HSV: Hue, Saturation, Value
# H: position in the spectrum
# S: color saturation ("purity")
# V: color brightness
# script de test et mise au point
use v5.14;
use strict;
use warnings;
use POSIX;
use Data::Dumper qw(Dumper);

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Simule un modulo
# usage: m*remainder(x,m) <=> (x)modulo(m)
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub remainder {
    my ( $x, $y ) = @_;
    return 0 unless $y && $x;
    return $x / $y - int( $x / $y );
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Converti rgb en hsv
# param : ligne rgb forme: r[0..255] g[0..255] b[0..255] Blalblabla...
# return : list hsv forme @hsv
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub rgb2hsv {    #pour le tri de palette methode GIMP
    my @rgb = @_;
    my ( $red, $green, $blue ) = @_;    #@rgb
    my @rgbs = ( sort { $a <=> $b } ( $red, $green, $blue ) );    # @rgb
    my ( $minc, $maxc ) = ( $rgbs[0], pop(@rgbs) );
    my $v = $maxc / 255.0;
    return ( 0.0, 0.0, sprintf( "%3.1f", $v * 100 ) ) if $minc == $maxc;
    my $deltac = $maxc - $minc;
    my $s      = $deltac / $maxc;
    my $rc     = ( $maxc - $red ) / $deltac;
    my $gc     = ( $maxc - $green ) / $deltac;
    my $bc     = ( $maxc - $blue ) / $deltac;
    my $h;

    if ( $red == $maxc ) {
        $h = $bc - $gc;
    }
    elsif ( $green == $maxc ) {
        $h = 2.0 + $rc - $bc;
    }
    else {
        $h = 4.0 + $gc - $rc;
    }
    $h = sprintf( "%.f", 360 * remainder( $h, 6 ) );    # sur 360 degrée
    $h += 360 if $h < 0;
    $s = sprintf( "%.1f", $s * 100 );
    $v = sprintf( "%.1f", $v * 100 );
    my @result = ( $h, $s, $v );
    return ( $h, $s, $v );
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# trie la liste @hsv sur un critere au choix H(ue) ou S(aturation) ou V(alue) en sens
# Ascendant 0 ou descendant 1. 
# param 1 : liste @hsv sous la forme ("h1 s1 v1", [h s v],...) 
# param 2 : critere H | S | V sous la forme 0 | 1 | 2
# param 3 : sens du tri ascendant | descendant sous la forme 0 | 1
# return : list hsv forme @hsv
# remarques: /!\ Passage param1 par reference \@TABLEAU i.e. sortHsv( \@keyData, 0, 0 ); /!\
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub sortHsv {
    my $hsvList   = shift @_;
    my $criterion = shift @_;
    my $order     = shift @_;
    my @out       = ();
    my ( $h, $s, $v );
    ( $criterion == 1 )
      ? ( $h, $s, $v ) = ( 1, 2, 0 )    # S puis V puis H
      : ( $criterion == 2 ) ? ( $h, $s, $v ) = ( 2, 0, 1 )    # V puis H puis S
      :                       $h = 0, $s = 1, $v = 2;         # H puis S puis V
    @out =
      map  { $_->[0] }
      sort { $a->[1] <=> $b->[1] || $a->[2] <=> $b->[2] || $a->[3] <=> $b->[3] }
      map  { [ $_, (split)[ $h, $s, $v ] ] } @{$hsvList};
    if ($order) { @out = reverse @out }
    return @out;
}

# __main__
my @data = <DATA>;
my @test = map{[$_,  (split )[0,1,2] ]} @data ;
#foreach (@test) { print $_->[0],":", $_->[1],$_->[2],$_->[3], "\n"};
say Dumper \@test;
my %data2sort;
my ( $h, $s, $v );
foreach my $rgb (@data) {
    my ( $h, $s, $v ) = rgb2hsv( split " ", $rgb );
    $data2sort{ $h . " " . $s . " " . $v } = $rgb;
}
say Dumper \%data2sort;
my @keyData    = keys %data2sort;
my @dataSorted = sortHsv( \@keyData, 0, 0 );    # trie sur les clés

#______________________ ZONE DATA TEST _______________________#
# R   G   B          H°   S%    V%
#136 116 115          3  15.4  53.3
# 25  12 255        243  95.3 100
#136  12 160        290  92.5  62.7
#185 200  12         65  94    78.4
# 69  32 122        265  73.8  47.8
#229  35  10          7  95.6  89.8
#136 115 115          0  15.4  53.3
#133 113 112          3  15.8  52.2
# 64  53  54        355  17.2  25.1
#153 129 129          0  15.7  60
__END__
136 116 115 #887374 couleur de fond
 25 12 255
136 12 160
185 200 12
69 32 122
229 35 10
136 115 115 #probleme
133 113 112
64 53 54
153 129 129
