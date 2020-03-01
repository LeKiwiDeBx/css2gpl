#!/usr/bin/perl -w -s
## HSV: Hue, Saturation, Value
# H: position in the spectrum
# S: color saturation ("purity")
# V: color brightness
#
# def rgb_to_hsv(r, g, b):
#     maxc = max(r, g, b)
#     minc = min(r, g, b)
#     v = maxc
#     if minc == maxc:
#         return 0.0, 0.0, v
#     s = (maxc-minc) / maxc
#     rc = (maxc-r) / (maxc-minc)
#     gc = (maxc-g) / (maxc-minc)
#     bc = (maxc-b) / (maxc-minc)
#     if r == maxc:
#         h = bc-gc
#     elif g == maxc:
#         h = 2.0+rc-bc
#     else:
#         h = 4.0+gc-rc
#     h = (h/6.0) % 1.0
#     return h, s, v
use strict;
use warnings;

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
# param : liste rgb forme r[0..255] g[0..255] b[0..255]
# return : list hsv forme @hsv
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub rgb2hsv {    #pour le tri de palette methode GIMP
    my @rgb = @_;
    my ( $red, $green, $blue ) = @rgb;
    my @rgbs = ( sort { $a <=> $b } @rgb );
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
    $h = sprintf( "%3.f", 360 * remainder( $h, 6 ) );    # sur 360 degrée
    $h += 360 if $h < 0;
    $s = sprintf( "%3.1f", $s * 100 );
    $v = sprintf( "%3.1f", $v * 100 );
    my @result = ( $h, $s, $v );
    return @result;
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# trie la liste @hsv sur un critere au choix H(ue) ou S(aturation) ou V(alue) en sens
# Ascendant 0 ou descendant 1
# param 1 : liste @hsv sous la forme ("h1 s1 v1", [h s v],...)
# param 2 : critere H | S | V sous la forme 0 | 1 | 2
# param 3 : sens du tri ascendant | descendant sous la forme 0 | 1
# return : list hsv forme @hsv
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub sortHsv {
    my @hsvList   = shift @_;
    # foreach(@hsvList){ print "hsvLis", $_ };
    my $criterion = shift @_;
    my $order     = shift @_;
    my @out       = ();
    my ( $h, $s, $v ) = ( 0, 1, 2 );
    if ( $criterion == 1 ) {
        ( $h, $s ) = ( $s, $h );
    }
    elsif ( $criterion == 2 ) {
        ( $h, $v ) = ( $v, $h );
    }
    @out = sort {
             ( split ' ', $a, 3 )[$h] <=> ( split ' ', $b, 3 )[$h]
          || ( split ' ', $a, 3 )[$s] <=> ( split ' ', $b, 3 )[$s]
          || ( split ' ', $a, 3 )[$v] <=> ( split ' ', $b, 3 )[$v]
    } @hsvList;
    if ($order) { @hsvList = reverse @hsvList }
    return @hsvList;
}

# __main__

my @data      = <DATA>;
my %data2sort = ();
my($h ,$s, $v);
foreach (@data) {
    print "data : ", $_;
    my($h ,$s, $v) = rgb2hsv( split " ", $_ );
    $data2sort{$h." ".$s." ".$v} = $_ ;
    printf "h : %s° s : %s%% v : %s%%\n",rgb2hsv( split " ", $_ );    #$h, $s, $v;
}
# print "nbre element data2sort :", scalar @data2sort, "\n" ;
 foreach my $key (keys %data2sort) {
      printf "debug : %s cle: %s\n", $data2sort{$key}, $key;
 }
# my @dataSorted = sortHsv( @data2sort, 0, 0 );
# print "\n###### sortie triées ##########\n";
# foreach (@dataSorted) {
#    # print $_, "\n";
# }

#______________________ ZONE DATA TEST _______________________#
# R   G   B          H°   S%    V%
#136 116 115          3  15.4  53.3
# 25  12 255        243  95.3 100
#136  12 160        290  92.5  62.7
#185 200  12         65  94    78.4
# 69  32 122        265  73.8  47.8
#229  35  10          7  95.6  89.8
__END__
136 116 115
25 12 255
136 12 160
185 200 12
69 32 122
229 35 10
