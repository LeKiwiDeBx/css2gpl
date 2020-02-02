#!/usr/bin/perl -w -s
# program:    css2gpl.pl
#             Extrait d'un fichier texte les couleurs (format css) et créé une
#             palette .gpl pour The GIMP.
#             Gère les format #abc #a1b2c3 rgb() rgba() hsl() hsla()
#             Ignore la transparence de (rgb|hsl)a 'transparent' et les couleurs
#             nommées
#             Ajoute au fichier palette.gpl un commentaire si dans le fichier
#             texte on le touve en commentaire, ie:
#               color: #ff0; /*What...is your favorite color? blue, No, yel-- auuuuuugh!*/
#             devient la ligne gpl
#               255 255 0 What...is your favorite color? blue, No, yel-- auuuuuugh!
# version:    0.1
# usage:      perl css2gpl.pl <nomFichier> <nomPalette.gpl>
# author:     LeKiwiDeBx
# date:       27/01/2020

use strict;
use warnings;
use File::Basename;
my $version = '0.1';
my $fCss;
my $fGpl;
my $Header =
  "GIMP Palette\nName: %s\nColumns: %s\n#\n";    # en tête du fichier GIMP
## variable ligne de commande `my` interdit
use vars qw/ $i /;    # fichier entrée texte ie -s="boCss.css"
use vars qw/ $o /;    # fichier gpl sans extension .gpl ie -o="TheGpl"
use vars qw/ $n /;    # nom de la palette ie: -n="namePalette"
use vars qw/ $c /;    # nombre de columns a presenter -c=6
my $patternComment  = ';\s*\/\*(.*)\*\/';    #extrait commentaire bout de ligne
my %IDlistNameColor = (
    'AliceBlue'            => 'F0F8FF',
    'BlueViolet'           => '8A2BE2',
    'AntiqueWhite'         => 'FAEBD7',
    'Aqua'                 => '00FFFF',
    'Aquamarine'           => '7FFFD4',
    'Azure'                => 'F0FFFF',
    'Beige'                => 'F5F5DC',
    'Bisque'               => 'FFE4C4',
    'Black'                => '000000',
    'BlanchedAlmond'       => 'FFEBCD',
    'Blue'                 => '0000FF',
    'Brown'                => 'A52A2A',
    'Chartreuse'           => '7FFF00',
    'BurlyWood'            => 'DEB887',
    'CadetBlue'            => '5F9EA0',
    'Chocolate'            => 'D2691E',
    'Coral'                => 'FF7F50',
    'CornflowerBlue'       => '6495ED',
    'Cornsilk'             => 'FFF8DC',
    'Crimson'              => 'DC143C',
    'Cyan'                 => '00FFFF',
    'DarkBlue'             => '00008B',
    'DarkCyan'             => '008B8B',
    'DarkGoldenRod'        => 'B8860B',
    'DarkGray'             => 'A9A9A9',
    'DarkGrey'             => 'A9A9A9',
    'DarkGreen'            => '006400',
    'DarkKhaki'            => 'BDB76B',
    'DarkMagenta'          => '8B008B',
    'DarkOliveGreen'       => '556B2F',
    'DarkOrange'           => 'FF8C00',
    'DarkOrchid'           => '9932CC',
    'DarkRed'              => '8B0000',
    'DarkSalmon'           => 'E9967A',
    'DarkSeaGreen'         => '8FBC8F',
    'DarkSlateBlue'        => '483D8B',
    'DarkSlateGray'        => '2F4F4F',
    'DarkSlateGrey'        => '2F4F4F',
    'DarkTurquoise'        => '00CED1',
    'DarkViolet'           => '9400D3',
    'DeepPink'             => 'FF1493',
    'DeepSkyBlue'          => '00BFFF',
    'DimGray'              => '696969',
    'DimGrey'              => '696969',
    'DodgerBlue'           => '1E90FF',
    'FireBrick'            => 'B22222',
    'FloralWhite'          => 'FFFAF0',
    'ForestGreen'          => '228B22',
    'Fuchsia'              => 'FF00FF',
    'Gainsboro'            => 'DCDCDC',
    'GhostWhite'           => 'F8F8FF',
    'Gold'                 => 'FFD700',
    'GoldenRod'            => 'DAA520',
    'Gray'                 => '808080',
    'Grey'                 => '808080',
    'Green'                => '008000',
    'GreenYellow'          => 'ADFF2F',
    'HoneyDew'             => 'F0FFF0',
    'HotPink'              => 'FF69B4',
    'IndianRed'            => 'CD5C5C',
    'Indigo'               => '4B0082',
    'Ivory'                => 'FFFFF0',
    'Khaki'                => 'F0E68C',
    'Lavender'             => 'E6E6FA',
    'LavenderBlush'        => 'FFF0F5',
    'LawnGreen'            => '7CFC00',
    'LemonChiffon'         => 'FFFACD',
    'LightBlue'            => 'ADD8E6',
    'LightCoral'           => 'F08080',
    'LightCyan'            => 'E0FFFF',
    'LightGoldenRodYellow' => 'FAFAD2',
    'LightGray'            => 'D3D3D3',
    'LightGrey'            => 'D3D3D3',
    'LightGreen'           => '90EE90',
    'LightPink'            => 'FFB6C1',
    'LightSalmon'          => 'FFA07A',
    'LightSeaGreen'        => '20B2AA',
    'LightSkyBlue'         => '87CEFA',
    'LightSlateGray'       => '778899',
    'LightSlateGrey'       => '778899',
    'LightSteelBlue'       => 'B0C4DE',
    'LightYellow'          => 'FFFFE0',
    'Lime'                 => '00FF00',
    'LimeGreen'            => '32CD32',
    'Linen'                => 'FAF0E6',
    'Magenta'              => 'FF00FF',
    'Maroon'               => '800000',
    'MediumAquaMarine'     => '66CDAA',
    'MediumBlue'           => '0000CD',
    'MediumOrchid'         => 'BA55D3',
    'MediumPurple'         => '9370DB',
    'MediumSeaGreen'       => '3CB371',
    'MediumSlateBlue'      => '7B68EE',
    'MediumSpringGreen'    => '00FA9A',
    'MediumTurquoise'      => '48D1CC',
    'MediumVioletRed'      => 'C71585',
    'MidnightBlue'         => '191970',
    'MintCream'            => 'F5FFFA',
    'MistyRose'            => 'FFE4E1',
    'Moccasin'             => 'FFE4B5',
    'NavajoWhite'          => 'FFDEAD',
    'Navy'                 => '000080',
    'OldLace'              => 'FDF5E6',
    'Olive'                => '808000',
    'OliveDrab'            => '6B8E23',
    'Orange'               => 'FFA500',
    'OrangeRed'            => 'FF4500',
    'Orchid'               => 'DA70D6',
    'PaleGoldenRod'        => 'EEE8AA',
    'PaleGreen'            => '98FB98',
    'PaleTurquoise'        => 'AFEEEE',
    'PaleVioletRed'        => 'DB7093',
    'PapayaWhip'           => 'FFEFD5',
    'PeachPuff'            => 'FFDAB9',
    'Peru'                 => 'CD853F',
    'Pink'                 => 'FFC0CB',
    'Plum'                 => 'DDA0DD',
    'PowderBlue'           => 'B0E0E6',
    'Purple'               => '800080',
    'RebeccaPurple'        => '663399',
    'Red'                  => 'FF0000',
    'RosyBrown'            => 'BC8F8F',
    'RoyalBlue'            => '041690',
    'SaddleBrown'          => '8B4513',
    'Salmon'               => 'FA8072',
    'SandyBrown'           => 'F4A460',
    'SeaGreen'             => '2E8B57',
    'SeaShell'             => 'FFF5EE',
    'Sienna'               => 'A0522D',
    'Silver'               => 'C0C0C0',
    'SkyBlue'              => '87CEEB',
    'SlateBlue'            => '6A5ACD',
    'SlateGray'            => '708090',
    'SlateGrey'            => '708090',
    'Snow'                 => 'FFFAFA',
    'SpringGreen'          => '00FF7F',
    'SteelBlue'            => '4682B4',
    'Tan'                  => 'D2B48C',
    'Teal'                 => '008080',
    'Thistle'              => 'D8BFD8',
    'Tomato'               => 'FF6347',
    'Turquoise'            => '40E0D0',
    'Violet'               => 'EE82EE',
    'Wheat'                => 'F5DEB3',
    'White'                => 'FFFFFF',
    'WhiteSmoke'           => 'F5F5F5',
    'Yellow'               => 'FFFF00',
    'YellowGreen'          => '9ACD32'
);
print
  "\nProgramme de création d'une palette .gpl à partir d'un fichier css\n";
print "version: $version\n";

#
# modulo function
#
sub remainder {
    my ( $a, $b ) = @_;
    return 0 unless $b && $a;

    # print $a / $b - int( $a / $b );
    return $a / $b - int( $a / $b );
}

#
#
#
sub loadFileCss {
    my $f = shift @_;
    print "\nRecherche le fichier: " . basename($f) . "\n";
    open( $fCss, "<", $f )
      or die "Echec ouverture du fichier css : $!";
}

#
#
#
sub writeHeaderFileGpl {
    my $f     = shift @_;
    my $NoExt = '(.+?)(\.[^\.]*+$|$)'; #suppr toute extension (.+?)(\.[^\.]+$|$)
    $f =~ /$NoExt/;
    open( $fGpl, ">", $1 . ".gpl" );
    printf( "${Header}",       $n, $c );
    printf( $fGpl "${Header}", $n, $c );
}

#
#
#
sub readFileCss {
    my $f = shift @_;
    my $l = "";
    open( $fCss, "<", $f ) or die "Echec ouverture du fichier css : $!";
    while ( defined( $l = <$fCss> ) ) {
        chomp $l;
        if ( extractHexa($l) ne '' ) {
            print hexa2rgb( extractHexa($l) ), " ", extractComment($l), "\n";
        }
        if ( extractRgbHsl($l) ne '' ) {
            print extractRgbHsl($l), " ", extractComment($l), "\n";
        }
    }
}

#
#
#
sub extractComment {
    my $line = shift @_;
    if ( $line =~ /$patternComment/ ) {
        my $cmt = $1;
        $cmt =~ s/^\s+|\s+$//g;             #trim: left and right
        $cmt =~ s/((\*\/)|(\/\*))\s*//g;    #suppr: espace*/espace/*espace
        return $cmt;
    }
    return "";
}

#
# !CSS4 #ff00ffaa | #f0fa ->canal alpha en hexa non implementé!
#
sub extractHexa {
    my $line    = shift @_;
    my $pattern = "#([a-fA-F0-9]{6})|#([a-fA-F0-9]{3})";
    my $match   = "";
    if ( $line =~ /$pattern/ ) {
        $match = defined $1 ? $1 : $2;
        return $match;
    }
    else { return $match; }
}

#
#
#
#
sub extractRgbHsl {
    my $line = shift @_;
    my $patternStrictRgb =
      '(rgb)a?\(\s*(\d{1,3})%\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%.*\)';
    my $patternStrictHsl =
'(?:hsl)a?\(\s*(\d*?\.?\d*)(deg|grad|rad|turn)\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%.*\)';
    my $patternRgbHsl =
      '(rgb|hsl)a?\(\s*(\d{1,3})\s*,\s*(\d{1,3})%?\s*,\s*(\d{1,3})%?.*\)';
    my $match = "";
    my $sRgb;
    my $sHsl;
    my @Rgb;
    my $sCmt;    # commentaire

    # https://developer.mozilla.org/fr/docs/Web/CSS/Type_color
    # pattern strict Rgb avec % -> 0..255 arrondi
    if ( $line =~ /$patternStrictRgb/ ) {
        my @rgb;
        my ( $t, $r, $g, $b ) = ( $1, $2 * 2.55, $3 * 2.55, $4 * 2.55 );
        $sRgb = sprintf( "%3.f %3.f %3.f", $r, $g, $b );

        # print $sRgb, "\n";
        return $sRgb;
    }

    #pattern strict Hsl $u=$2:deg-grad-rad-turn -> deg
    if ( $line =~ /$patternStrictHsl/ ) {
        my ( $h, $u, $s, $l ) = ( $1, $2, $3, $4 );
        if ( $u =~ /deg/ ) {
            $h = 360 * remainder( $h, 360.0 );
        }
        elsif ( $u =~ /grad/ ) {
            $h = 360 * remainder( $h * ( 180.0 / 200.0 ), 360 );
        }
        elsif ( $u =~ /rad/ ) {
            $h = 360 * remainder( $h * 180.0 / 3.14159, 360.0 );
        }
        elsif ( $u =~ /turn/ ) { $h = 360 * remainder( $h * 360.0, 360 ); }
        else {
            return 0;
        }
        $sRgb = hsl2Rgb( $h, $s, $l );
        return $sRgb;
    }

    if ( $line =~ /$patternRgbHsl/ ) {
        my ( $t, $r, $g, $b ) = ( $1, $2, $3, $4 );
        if ( $t =~ /rgb/ ) {
            $sRgb = sprintf( "%3d %3d %3d", $r, $g, $b );

            #  print("rgb: ${sRgb}\n");
        }
        elsif ( $t =~ /hsl/ ) {    # les positions r g b correspond h s l
            $sRgb = hsl2Rgb( $r, $g, $b );

# my ( $h, $s, $l ) = (
#     sprintf( "%.5f", $r / 360.0 ),
#     sprintf( "%.5f", $g / 100.0 ),
#     sprintf( "%.5f", $b / 100.0 )
# );
#
# #todo test s et l entre [0..1]
# my ( $r, $g, $b ) = ( $l * 255.0, $l * 255.0, $l * 255.0 );
# if ( $s != 0.0 ) {
#     my $var_2 =
#       $l < 0.5 ? $l * ( 1.0 + $s ) : ( $l + $s ) - ( $s * $l );
#     my $var_1 = 2.0 * $l - $var_2;
#     $r = 255 * hue2Rgb( $var_1, $var_2, $h + ( 1.0 / 3.0 ) );
#     $g = 255 * hue2Rgb( $var_1, $var_2, $h );
#     $b = 255 * hue2Rgb( $var_1, $var_2, $h - ( 1.0 / 3.0 ) );
# }
# $sRgb = sprintf( "%-.f %-.f %-.f", $r, $g, $b );
# print $sRgb. "\n";
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
#
#
        }
        return $sRgb;
    }
    else { return "" }
}

#
#
#
sub hsl2Rgb {
    my ( $h, $s, $l ) = @_;
    ( $h, $s, $l ) = (
        sprintf( "%.5f", $h / 360.0 ),
        sprintf( "%.5f", $s / 100.0 ),
        sprintf( "%.5f", $l / 100.0 )
    );
    my ( $r, $g, $b ) = ( $l * 255.0, $l * 255.0, $l * 255.0 );
    if ( $s != 0.0 ) {
        my $var_2 =
          $l < 0.5 ? $l * ( 1.0 + $s ) : ( $l + $s ) - ( $s * $l );
        my $var_1 = 2.0 * $l - $var_2;
        $r = 255 * hue2Rgb( $var_1, $var_2, $h + ( 1.0 / 3.0 ) );
        $g = 255 * hue2Rgb( $var_1, $var_2, $h );
        $b = 255 * hue2Rgb( $var_1, $var_2, $h - ( 1.0 / 3.0 ) );
    }
    my $sRgb = sprintf( "%3.f %3.f %3.f", $r, $g, $b );
    return $sRgb;
}

#
#
#
sub hue2Rgb {
    my ( $v1, $v2, $vH ) = @_;
    while ( $vH < 0.0 ) { $vH += 1.0 }
    while ( $vH > 1.0 ) { $vH -= 1.0 }
    if ( 6 * $vH < 1.0 ) { return ( $v1 + ( $v2 - $v1 ) * 6.0 * $vH ) }
    if ( 2 * $vH < 1.0 ) { return $v2 }
    if ( 3 * $vH < 2.0 ) {
        return ( $v1 + ( $v2 - $v1 ) * ( 4.0 - 6.0 * $vH ) );
    }
    return $v1;
}

#
#
#
sub hexa2rgb {
    my $hexa = shift @_;
    my @rgb;
    my $sRgb;
    if ( length($hexa) == 6 ) {
        push @rgb, substr( $hexa, 0, 2 ), substr( $hexa, 2, 2 ),
          substr( $hexa, 4, 2 );
    }
    elsif ( length($hexa) == 3 ) {
        push @rgb, substr( $hexa, 0, 1 ) . substr( $hexa, 0, 1 ),
          substr( $hexa, 1, 1 ) . substr( $hexa, 1, 1 ),
          substr( $hexa, 2, 1 ) . substr( $hexa, 2, 1 );
    }
    foreach (@rgb) {
        $sRgb .= sprintf( "%3d ", hex $_ );
    }
    $sRgb =~ s/\s$//g;
    return $sRgb;
}

#
# main
#
my $File    = $i;    # recupere 1er argument
my $FileGpl = $o;    # recupere 2eme argument

loadFileCss($File);
print "\nEcriture du fichier gpl\n\n";
writeHeaderFileGpl($FileGpl);
readFileCss($File);
print "\n";
