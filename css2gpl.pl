#!/usr/bin/perl -w -s
# -*- coding: utf-8 -*-
# program:    css2gpl.pl
#             Extrait d'un fichier texte les couleurs (format css) et créé une
#             palette au format .gpl pour The GIMP.
#             Gère les format #abc #a1b2c3 rgb() rgba() hsl() hsla()
#             Gère les couleurs nommées
#             Ignore la transparence de (rgb|hsl)a 'transparent' absent du format gpl
#             Ajoute au fichier palette.gpl un commentaire si dans le fichier
#             texte on le touve en commentaire, ie:
#               color: #ff0; /*What...is your favorite color? blue, No, yel-- auuuuuugh!*/
#             devient la ligne gpl
#               255 255 0 What...is your favorite color? blue, No, yel-- auuuuuugh!
# version:    alpha 0.1
# usage:      perl css2gpl.pl -i=<nomFichier.css> -o=<nomFichierPalette[.gpl]> -n=<nomPalette> -c=<nbreColonne>
# author:     LeKiwiDeBx
# date:       27/01/2020
# disclaimer: [=     This code is written by humans for humans ® (°}<Yeah!    =]
#
#      Copyright  © 2020 </{LeKiwiDeBx}>  GNU General Public License
#
#
#  This file is part of css2gpl.pl.
#
# css2gpl.pl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# css2gpl.pl is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with css2gpl.pl.  If not, see <https://www.gnu.org/licenses/>
#   ,= ,-_-. =.
#  ((_/)o o(\_))
#   `-'(. .)`-'
#       \_/
#                                                     GNU General Public License
use strict ;
use warnings ;
use File::Basename ;
my $version = '0.1' ;
my $fCss ;    # descripteur fichier CSS
my $fGpl ;    # descripteur fichier GPL
my $Header       = "GIMP Palette\nName: %s\nColumns: %s\n#\n" ;    # en tête du fichier GIMP
my $Body         = "" ;                                            # corps du fichier GIMP
my %ColorComment = () ;
;    # ligne du fichier gpl :  <Rouge> <Vert> <Bleu> <Commentaires>

# variable ligne de commande `my` interdit
use vars qw/ $i / ;    # fichier entrée texte ie -s="boCss.css"
use vars qw/ $o / ;    # fichier gpl sans extension .gpl ie -o="TheGpl"
use vars qw/ $n / ;    # nom de la palette ie: -n="namePalette"
use vars qw/ $c / ;    # nombre de columns a presenter -c=6
my $patternComment = ';\s*\/\*(.*)\*\/' ;    #extrait commentaire bout de ligne
my %IDlistNameColor = (
                        'aliceblue'            => 'F0F8FF',
                        'antiquewhite'         => 'FAEBD7',
                        'aqua'                 => '00FFFF',
                        'aquamarine'           => '7FFFD4',
                        'azure'                => 'F0FFFF',
                        'beige'                => 'F5F5DC',
                        'bisque'               => 'FFE4C4',
                        'black'                => '000000',
                        'blanchedalmond'       => 'FFEBCD',
                        'blue'                 => '0000FF',
                        'blueviolet'           => '8A2BE2',
                        'brown'                => 'A52A2A',
                        'burlywood'            => 'DEB887',
                        'cadetblue'            => '5F9EA0',
                        'chartreuse'           => '7FFF00',
                        'chocolate'            => 'D2691E',
                        'coral'                => 'FF7F50',
                        'cornflowerblue'       => '6495ED',
                        'cornsilk'             => 'FFF8DC',
                        'crimson'              => 'DC143C',
                        'cyan'                 => '00FFFF',
                        'darkblue'             => '00008B',
                        'darkcyan'             => '008B8B',
                        'darkgoldenrod'        => 'B8860B',
                        'darkgray'             => 'A9A9A9',
                        'darkgrey'             => 'A9A9A9',
                        'darkgreen'            => '006400',
                        'darkkhaki'            => 'BDB76B',
                        'darkmagenta'          => '8B008B',
                        'darkolivegreen'       => '556B2F',
                        'darkorange'           => 'FF8C00',
                        'darkorchid'           => '9932CC',
                        'darkred'              => '8B0000',
                        'darksalmon'           => 'E9967A',
                        'darkseagreen'         => '8FBC8F',
                        'darkslateblue'        => '483D8B',
                        'darkslategray'        => '2F4F4F',
                        'darkslategrey'        => '2F4F4F',
                        'darkturquoise'        => '00CED1',
                        'darkviolet'           => '9400D3',
                        'deeppink'             => 'FF1493',
                        'deepskyblue'          => '00BFFF',
                        'dimgray'              => '696969',
                        'dimgrey'              => '696969',
                        'dodgerblue'           => '1E90FF',
                        'firebrick'            => 'B22222',
                        'floralwhite'          => 'FFFAF0',
                        'forestgreen'          => '228B22',
                        'fuchsia'              => 'FF00FF',
                        'gainsboro'            => 'DCDCDC',
                        'ghostwhite'           => 'F8F8FF',
                        'gold'                 => 'FFD700',
                        'goldenrod'            => 'DAA520',
                        'gray'                 => '808080',
                        'grey'                 => '808080',
                        'green'                => '008000',
                        'greenyellow'          => 'ADFF2F',
                        'honeydew'             => 'F0FFF0',
                        'hotpink'              => 'FF69B4',
                        'indianred'            => 'CD5C5C',
                        'indigo'               => '4B0082',
                        'ivory'                => 'FFFFF0',
                        'khaki'                => 'F0E68C',
                        'lavender'             => 'E6E6FA',
                        'lavenderblush'        => 'FFF0F5',
                        'lawngreen'            => '7CFC00',
                        'lemonchiffon'         => 'FFFACD',
                        'lightblue'            => 'ADD8E6',
                        'lightcoral'           => 'F08080',
                        'lightcyan'            => 'E0FFFF',
                        'lightgoldenrodyellow' => 'FAFAD2',
                        'lightgray'            => 'D3D3D3',
                        'lightgrey'            => 'D3D3D3',
                        'lightgreen'           => '90EE90',
                        'lightpink'            => 'FFB6C1',
                        'lightsalmon'          => 'FFA07A',
                        'lightseagreen'        => '20B2AA',
                        'lightskyblue'         => '87CEFA',
                        'lightslategray'       => '778899',
                        'lightslategrey'       => '778899',
                        'lightsteelblue'       => 'B0C4DE',
                        'lightyellow'          => 'FFFFE0',
                        'lime'                 => '00FF00',
                        'limegreen'            => '32CD32',
                        'linen'                => 'FAF0E6',
                        'magenta'              => 'FF00FF',
                        'maroon'               => '800000',
                        'mediumaquamarine'     => '66CDAA',
                        'mediumblue'           => '0000CD',
                        'mediumorchid'         => 'BA55D3',
                        'mediumpurple'         => '9370DB',
                        'mediumseagreen'       => '3CB371',
                        'mediumslateblue'      => '7B68EE',
                        'mediumspringgreen'    => '00FA9A',
                        'mediumturquoise'      => '48D1CC',
                        'mediumvioletred'      => 'C71585',
                        'midnightblue'         => '191970',
                        'mintcream'            => 'F5FFFA',
                        'mistyrose'            => 'FFE4E1',
                        'moccasin'             => 'FFE4B5',
                        'navajowhite'          => 'FFDEAD',
                        'navy'                 => '000080',
                        'oldlace'              => 'FDF5E6',
                        'olive'                => '808000',
                        'olivedrab'            => '6B8E23',
                        'orange'               => 'FFA500',
                        'orangered'            => 'FF4500',
                        'orchid'               => 'DA70D6',
                        'palegoldenrod'        => 'EEE8AA',
                        'palegreen'            => '98FB98',
                        'paleturquoise'        => 'AFEEEE',
                        'palevioletred'        => 'DB7093',
                        'papayawhip'           => 'FFEFD5',
                        'peachpuff'            => 'FFDAB9',
                        'peru'                 => 'CD853F',
                        'pink'                 => 'FFC0CB',
                        'plum'                 => 'DDA0DD',
                        'powderblue'           => 'B0E0E6',
                        'purple'               => '800080',
                        'rebeccapurple'        => '663399',
                        'red'                  => 'FF0000',
                        'rosybrown'            => 'BC8F8F',
                        'royalblue'            => '041690',
                        'saddlebrown'          => '8B4513',
                        'salmon'               => 'FA8072',
                        'sandybrown'           => 'F4A460',
                        'seagreen'             => '2E8B57',
                        'seashell'             => 'FFF5EE',
                        'sienna'               => 'A0522D',
                        'silver'               => 'C0C0C0',
                        'skyblue'              => '87CEEB',
                        'slateblue'            => '6A5ACD',
                        'slategray'            => '708090',
                        'slategrey'            => '708090',
                        'snow'                 => 'FFFAFA',
                        'springgreen'          => '00FF7F',
                        'steelblue'            => '4682B4',
                        'tan'                  => 'D2B48C',
                        'teal'                 => '008080',
                        'thistle'              => 'D8BFD8',
                        'tomato'               => 'FF6347',
                        'turquoise'            => '40E0D0',
                        'violet'               => 'EE82EE',
                        'wheat'                => 'F5DEB3',
                        'white'                => 'FFFFFF',
                        'whitesmoke'           => 'F5F5F5',
                        'yellow'               => 'FFFF00',
                        'yellowgreen'          => '9ACD32',
                      ) ;
print "\nProgramme de création d'une palette .gpl à partir d'un fichier css\n" ;
print "version: $version\n" ;

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Simule un modulo
# usage: m*remainder(x,m) <=> (x)modulo(m)
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub remainder
  {
    my ( $a, $b ) = @_ ;
    return 0 unless $b && $a ;

    # print $a / $b - int( $a / $b );
    return $a / $b - int( $a / $b ) ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Ouvre en lecture le fichier CSS à analyser
# param: nom du fichier
# return:
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub loadFileCss
  {
    my $f = shift @_ ;
    print "\nRecherche le fichier: " . basename($f) . "\n" ;
    open( $fCss, "<", $f )
      or die "Echec ouverture du fichier css : $!" ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Ouvre en ecriture le fichier GPL a crèer et ecrit l'en tête GPL
# param: nom du fichier
# return:
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub writeHeaderFileGpl
  {
    my $f     = shift @_ ;
    my $NoExt = '(.+?)(\.[^\.]*+$|$)' ;    #suppr toute extension (.+?)(\.[^\.]+$|$)
    $f =~ /$NoExt/ ;
    open( $fGpl, ">", $1 . ".gpl" ) ;
    printf( "${Header}",       $n, $c ) ;    # sortie ecran
    printf( $fGpl "${Header}", $n, $c ) ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Ouvre en ecriture le fichier GPL ecrit le body
# param: nom du fichier
# return: KeDal
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub writeBodyFileGpl
  {
    my $f     = shift @_ ;
    my $NoExt = '(.+?)(\.[^\.]*+$|$)' ;    #suppr toute extension (.+?)(\.[^\.]+$|$)
    $f =~ /$NoExt/ ;
    open( $fGpl, ">>", $1 . ".gpl" ) ;
    print($Body ) ;                        #sortie ecran
    return my $success = print $fGpl $Body ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Ouvre en lecture le fichier CSS à analyser
# param: nom du fichier
# return: à l'ecran (version alpha) les couleurs et commentaire format GPL
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub readFileCss
  {
    my $f = shift @_ ;
    my $l = "" ;
    open( $fCss, "<", $f ) or die "Echec ouverture du fichier css : $!" ;
    while ( defined( $l = <$fCss> ) )
      {
        chomp $l ;
        if ( extractHexa($l) ne '' )
          {
            $Body .= doLineGpl( hexa2rgb( extractHexa($l) ), extractComment($l) ) . "\n" ;

          }
        if ( extractRgbHsl($l) ne '' )
          {
            $Body .= doLineGpl( extractRgbHsl($l), extractComment($l) ) . "\n" ;
          }
        my @colorNameRgb = extractColorNamed($l) ;
        if (@colorNameRgb)
          {
            foreach my $rgb (@colorNameRgb)
              {
                $Body .= doLineGpl( $rgb, extractComment($l) ) . "\n" ;
              }
          }
      }
    $Body = join( "\n", sort split( "\n", $Body ) ) ;
    return $Body ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Extrait du fichier CSS le commentaire de la ligne et le formate GPL
# param: ligne en cours du fichier CSS
# return: le commentaire format GPL
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub extractComment
  {
    my $line = shift @_ ;
    if ( $line =~ /$patternComment/ )
      {
        my $cmt = $1 ;
        $cmt =~ s/^\s+|\s+$//g ;             #trim: left and right
        $cmt =~ s/((\*\/)|(\/\*))\s*//g ;    #suppr: espace*/espace/*espace
        return $cmt ;
      }
    return "" ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Extrait du fichier CSS le format #hexa[3 ou 6]
# param: ligne en cours du fichier CSS
# return: le format hexa de la couleur
# /!\ CSS4 #ff00ffaa | #f0fa ->canal alpha en hexa non implementé /!\
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub extractHexa
  {
    my $line    = shift @_ ;
    my $pattern = "#([a-fA-F0-9]{6})|#([a-fA-F0-9]{3})" ;    # code #ABCDEF ou #ABC
    my $match   = "" ;
    if ( $line =~ /$pattern/ )
      {
        $match = defined $1 ? $1 : $2 ;
        return $match ;
      }
    else { return $match ; }
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Extrait du fichier CSS une couleur nommée
# param: ligne en cours du fichier CSS
# return: le format gpl de la couleur ou une liste couleur (cas des gradient)
# /!\ il y' a plus de 140 couleurs nommées car grey=gray => 148 couleurs     /!\
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub extractColorNamed
  {
    my $line = shift @_ ;
    my @rgb  = () ;

    #my @key = keys(%IDlistNameColor);
    foreach my $colorName ( keys(%IDlistNameColor) )
      {
        if ( my $test = ( $line =~ /:.*(?:\s*|,|:)\b($colorName)\b.*;/i ) )    #capture que le dernier
          {
            push @rgb, colorName2rgb($colorName) ;
          }
      }
    return @rgb ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Extrait du fichier CSS le format:
# RGB strict: rgb(R%, G%, B%) ou rgba(R%, G%, B%, A%)
# HSL strict: hsl(H~unitAngle, S%, L%) ou hsl(H~uAngle, S%, L%, A%)
# RGB|HSL: rgb(R[0..255], G[0..255], B[0..255])
#          rgba(R[0..255], G[0..255], B[0..255], A)
#          hsl(H, S%, L%)
#          hsla(H, S%, L%, A)
# param: ligne en cours ddu fichier CSS
# return: le format GPL de la couleur
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub extractRgbHsl
  {
    my $line             = shift @_ ;
    my $patternStrictRgb = '(rgb)a?\(\s*(\d{1,3})%\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%.*\)' ;
    my $patternStrictHsl = '(?:hsl)a?\(\s*(\d*?\.?\d*)(deg|grad|rad|turn)\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%.*\)' ;
    my $patternRgbHsl    = '(rgb|hsl)a?\(\s*(\d{1,3})\s*,\s*(\d{1,3})%?\s*,\s*(\d{1,3})%?.*\)' ;
    my $match            = "" ;
    my $sRgb ;
    my $sHsl ;
    my @Rgb ;
    my $sCmt ;    # commentaire

    # https://developer.mozilla.org/fr/docs/Web/CSS/Type_color
    # pattern strict Rgb avec % -> 0..255 arrondi
    if ( $line =~ /$patternStrictRgb/ )
      {
        my @rgb ;
        my ( $t, $r, $g, $b ) = ( $1, $2 * 2.55, $3 * 2.55, $4 * 2.55 ) ;
        $sRgb = sprintf( "%3.3f %3.3f %3.3f", $r, $g, $b ) ;    #arrondi float
        $sRgb =~ s/^\s+|\s+$//g ;
        return $sRgb ;
      }

    #pattern strict Hsl $u=$2:deg-grad-rad-turn -> deg
    if ( $line =~ /$patternStrictHsl/ )
      {
        my ( $h, $u, $s, $l ) = ( $1, $2, $3, $4 ) ;
        if ( $u =~ /deg/ )
          {
            $h = 360 * remainder( $h, 360.0 ) ;
          }
        elsif ( $u =~ /grad/ )
          {
            $h = 360 * remainder( $h * ( 180.0 / 200.0 ), 360 ) ;
          }
        elsif ( $u =~ /rad/ )
          {
            $h = 360 * remainder( $h * 180.0 / 3.14159, 360.0 ) ;
          }
        elsif ( $u =~ /turn/ ) { $h = 360 * remainder( $h * 360.0, 360 ) ; }
        else
          {
            return 0 ;
          }
        $sRgb = hsl2Rgb( $h, $s, $l ) ;
        $sRgb =~ s/^\s+|\s+$//g ;
        return $sRgb ;
      }

    if ( $line =~ /$patternRgbHsl/ )
      {
        my ( $t, $r, $g, $b ) = ( $1, $2, $3, $4 ) ;
        if ( $t =~ /rgb/ )
          {
            $sRgb = sprintf( "%3d %3d %3d", $r, $g, $b ) ;
          }
        elsif ( $t =~ /hsl/ )
          {    # les positions r g b correspond h s l
            $sRgb = hsl2Rgb( $r, $g, $b ) ;
            #
            # def HSL_to_RGB(h,s,l):
            #     ''' Converts HSL colorspace (Hue/Saturation/Value) to RGB colorspace.
            #         Formula from http://www.easyrgb.com/math.php?MATH=M19#text19
            #
            #         Input:
            #             h (float) : Hue (0...1, but can be above or below
            #                               (This is a rotation around the chromatic circle))
            #             s (float) : Saturation (0...1)    (0=toward grey, 1=pure color)
            #             l (float) : Lightness (0...1)     (0=black 0.5=pure color 1=white)
            #
            #         Ouput:
            #             (r,g,b) (integers 0...255) : Corresponding RGB values
            #
            #         Examples:
            #             >>> print HSL_to_RGB(0.7,0.7,0.6)
            #             (110, 82, 224)
            #             >>> r,g,b = HSL_to_RGB(0.7,0.7,0.6)
            #             >>> print g
            #             82
            #     '''
            #     def Hue_2_RGB( v1, v2, vH ):
            #         while vH<0.0: vH += 1.0
            #         while vH>1.0: vH -= 1.0
            #         if 6*vH < 1.0 : return v1 + (v2-v1)*6.0*vH
            #         if 2*vH < 1.0 : return v2
            #         if 3*vH < 2.0 : return v1 + (v2-v1)*((2.0/3.0)-vH)*6.0
            #         return v1
            #
            #     if not (0 <= s <=1): raise ValueError,"s (saturation) parameter must be between 0 and 1."
            #     if not (0 <= l <=1): raise ValueError,"l (lightness) parameter must be between 0 and 1."
            #
            #     r,b,g = (l*255,)*3
            #     if s!=0.0:
            #        if l<0.5 : var_2 = l * ( 1.0 + s )
            #        else     : var_2 = ( l + s ) - ( s * l )
            #        var_1 = 2.0 * l - var_2
            #        r = 255 * Hue_2_RGB( var_1, var_2, h + ( 1.0 / 3.0 ) )
            #        g = 255 * Hue_2_RGB( var_1, var_2, h )
            #        b = 255 * Hue_2_RGB( var_1, var_2, h - ( 1.0 / 3.0 ) )
            #
            #     return (int(round(r)),int(round(g)),int(round(b)))
            #
          }
        $sRgb =~ s/^\s+|\s+$//g ;
        return $sRgb ;
      }
    else { return "" }
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Conversion valeur HSL à RGB
# param: ligne en cours ddu fichier CSS
# return: le format GPL de la couleur
# sourcing:
# + Converts HSL colorspace (Hue/Saturation/Value) to RGB colorspace.
#         Formula from http://www.easyrgb.com/math.php?MATH=M19#text19
# + un code source python ;)
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub hsl2Rgb
  {
    my ( $h, $s, $l ) = @_ ;
    ( $h, $s, $l ) = ( sprintf( "%.5f", $h / 360.0 ), sprintf( "%.5f", $s / 100.0 ), sprintf( "%.5f", $l / 100.0 ) ) ;
    my ( $r, $g, $b ) = ( $l * 255.0, $l * 255.0, $l * 255.0 ) ;
    if ( $s != 0.0 )
      {
        my $var_2 =
          $l < 0.5 ? $l * ( 1.0 + $s ) : ( $l + $s ) - ( $s * $l ) ;
        my $var_1 = 2.0 * $l - $var_2 ;
        $r = 255 * hue2Rgb( $var_1, $var_2, $h + ( 1.0 / 3.0 ) ) ;
        $g = 255 * hue2Rgb( $var_1, $var_2, $h ) ;
        $b = 255 * hue2Rgb( $var_1, $var_2, $h - ( 1.0 / 3.0 ) ) ;
      }
    my $sRgb = sprintf( "%3.3f %3.3f %3.3f", $r, $g, $b ) ;    #arrondi float
    $sRgb =~ s/^\s+|\s+$//g ;
    return $sRgb ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Sous-Routine de conversion valeur HSL à RGB appel de hsl2Rgb
# param: traitemet pour obtenir HUE
# return: valeur parametrée
# sourcing:
# + Converts HSL colorspace (Hue/Saturation/Value) to RGB colorspace.
#      (obsolete)   Formula from http://www.easyrgb.com/math.php?MATH=M19#text19
# + NEW! Formula from https://www.easyrgb.com/en/math.php
# + un code source python ;)
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub hue2Rgb
  {
    my ( $v1, $v2, $vH ) = @_ ;
    while ( $vH < 0.0 ) { $vH += 1.0 }
    while ( $vH > 1.0 ) { $vH -= 1.0 }
    if ( 6 * $vH < 1.0 ) { return ( $v1 + ( $v2 - $v1 ) * 6.0 * $vH ) }
    if ( 2 * $vH < 1.0 ) { return $v2 }
    if ( 3 * $vH < 2.0 )
      {
        return ( $v1 + ( $v2 - $v1 ) * ( 4.0 - 6.0 * $vH ) ) ;
      }
    return $v1 ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Conversion valeurs hexadecimales to RGB
# param: code hexadecimal de la couleur
# return: le format GPL de la couleur
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub hexa2rgb
  {
    my $hexa = shift @_ ;
    my @rgb ;
    my $sRgb ;
    if ( length($hexa) == 6 )
      {
        push @rgb, substr( $hexa, 0, 2 ), substr( $hexa, 2, 2 ), substr( $hexa, 4, 2 ) ;
      }
    elsif ( length($hexa) == 3 )
      {
        push @rgb, substr( $hexa, 0, 1 ) . substr( $hexa, 0, 1 ),
          substr( $hexa, 1, 1 ) . substr( $hexa, 1, 1 ),
          substr( $hexa, 2, 1 ) . substr( $hexa, 2, 1 ) ;
      }
    foreach (@rgb)
      {
        $sRgb .= sprintf( "%03d ", hex $_ ) ;
      }
    $sRgb =~ s/^\s+|\s+$//g ;    #trim blanc debut et final
    return $sRgb ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Converti le rgb format gpl en hexa pour l'inclure dans le commentaire
# param: le color rgb 255 255 255 format gpl
# return: en format hexa ABCDEF
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub rgb2hexa
  {
    my $rgb = shift @_ ;
    $rgb =~ s/^\s+|\s+$//g ;
    $rgb =~ s/(0{1,2})(\d+)/$2/g ;   #enleve les 1 ou 2 zero debut de chaque r g b, ie: 009 -> 9 | 080 -> 80 | 125 ->125
    my ( $r, $g, $b ) = split /\s+/, $rgb ;
    my $hexa = sprintf( "\%2.2X\%2.2X\%2.2X", $r, $g, $b ) ;    #3x2digits complete par 0
    return $hexa ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Converti "$key<les couleurs nommées>"=>"$value<code hexa>" au format rgb de gpl
# param: la couleur nommées $key de %ColorComment
# return: en format gpl $R[0..255] $G[0..255] $B[0..255] ie: 000 255 068
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub colorName2rgb
  {
    my $colorName = shift @_ ;
    my @rgb       = $IDlistNameColor{ lc $colorName } =~ /([0-9A-Fa-f]{2})/g ;    # ABCDEF->('AB','CD','EF')
    my $sRgb ;
    foreach (@rgb)
      {
        $sRgb .= sprintf( "%03d ", hex $_ ) ;                                     #force en hexa et converti en decimal
      }
    $sRgb =~ s/\s$//g ;                                                           #trim blanc final
    return $sRgb ;
  }

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Fait la ligne gpl au format <R(0..255)> <G(0..255)> <B(0..255)> <#codeHexa [color named] [comments]>
# param: liste couleur au format + le commentaire extrait
# + le code hexa dans les commentaires n'est pas obligatoire, c'est pour aider
#   l'utilisateur de la palette dans GIMP
# Ecrit dans la hash table $keys= couleur au format $value= commentaire extrait
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub doLineGpl
  {
    my ( $color, $comment ) = @_ ;
    $color =~ s/(0{1,2})(\d+)/$2/g ;
    $color =~ s/^\s+|\s+$//g ;

    #enleve les 0 en trop (pour la conversion en hexa)
    unless ( exists( $ColorComment{$color} ) )
      {
        $ColorComment{$color} = rgb2hexa($color) . " " . $comment ;
      }
    else
      {
        $ColorComment{$color} .= " " . $comment ;
      }
    my ( $r, $g, $b ) = split( /\s+/, $color ) ;    #recupere les r g b sur les espaces
    my %rIDlistNameColor = reverse %IDlistNameColor ;
    if ( exists( $rIDlistNameColor{ rgb2hexa($color) } ) )
      {
        return (
                     sprintf( "%3d %3d %3d ", $r, $g, $b )
                   . sprintf( "%20s ",    $rIDlistNameColor{ rgb2hexa($color) } )
                   . sprintf( "%-48.48s", $ColorComment{$color} ) ) ;
      }
    else
      {
        return ( sprintf( "%3d %3d %3d ", $r, $g, $b ) . $ColorComment{$color} ) ;
      }

    #print "\nDoLineGpl: \n", join( "\n", %ColorComment );
  }

#  ___________________________________________________________________________
# |                                                                           |
# |                         </{Version α}>     (°}<Ouais!                     |
# |___________________________________________________________________________|
my $File    = $i ;    # recupere 1er argument
my $FileGpl = $o ;    # recupere 2e argument
loadFileCss($File) ;
print "\nEcriture du fichier gpl\n\n" ;
writeHeaderFileGpl($FileGpl) ;
readFileCss($File) ;
writeBodyFileGpl($FileGpl) ;

# ZONE TEST ====================================================================================
#test doLineGpl
my $colorTest_1   = "15 14 13" ;
my $colorTest_2   = "127 0 96" ;
my $commentTest_1 = "commentaire 1" ;
my $commentTest_2 = "commentaire 2" ;
my $commentTest_3 = "commentaire 3" ;

# doLineGpl( $colorTest_1, $commentTest_1 );
# doLineGpl( $colorTest_1, $commentTest_2 );
# doLineGpl( $colorTest_2, $commentTest_3 );
#print "couleur : ", colorName2rgb("Chocolate");    #D2691E
# print extractColorNamed("div {  background: linear-gradient(to right, red, orange, yellow, green, blue, indigo, violet);}"  );
print "\n" ;
