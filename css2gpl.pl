#!/usr/bin/perl -w -s
# -*- coding: utf-8 -*-
# program:    css2gpl.pl
#             Extrait d'un fichier texte les couleurs (format css) et créé une
#             palette au format .gpl pour The GIMP.
#             Gère les format #abc #a1b2c3 rgb() rgba() hsl() hsla()
#             Gère les couleurs nommées
#             Gère les gradients avec hexadecimal (3 et 6 digits) et couleurs nommées
#             Ignore la transparence de (rgb|hsl)a 'transparent' absent du format gpl
#             Ajoute au fichier palette.gpl un commentaire si dans le fichier
#             texte on le touve en commentaire, ie:
#               color: #ff0; /*What...is your favorite color? blue, No, yel-- auuuuuugh!*/
#             devient la ligne gpl
#               255 255 0 What...is your favorite color? blue, No, yel-- auuuuuugh!
# version:    beta 1.0
# usage:      perl css2gpl.pl -i=<nomFichier.css> [-o=<nomFichierPalette[.gpl]>] [-n=<nomPalette>] [-c=<nbreColonne>]
# author:     LeKiwiDeBx
# date:       27/01/2020
# disclaimer: [=     This code is written by humans for humans ® (°}<Yeah!    =]
#
#      Copyright  © 2020 </{LeKiwiDeBx}>  GNU General Public License  ★★★★★
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
#
#                                                   GNU General Public License
use v5.14;    # utilisation de say
use strict;
use warnings;
use File::Basename;
use Data::Dumper qw(Dumper);    ### <== #### DEBUGAGE !!!!!!!!!!!!!  ###########
my $version = 'Beta 1.0';
my $fCss;                       # descripteur fichier CSS
my $fGpl;                       # descripteur fichier GPL
my $Header =
  "GIMP Palette\nName: %s\nColumns: %s\n#\n";    # en tête du fichier GIMP
my $Body         = "";                           # corps du fichier GIMP
my %ColorComment = ();
;    # ligne du fichier gpl :  <Rouge> <Vert> <Bleu> <Commentaires>

# variable ligne de commande `my` interdit
use vars qw/ $i /;    # fichier entrée texte ie -s="boCss.css"
use vars qw/ $o /;    # fichier gpl sans extension .gpl ie -o="TheGpl"
use vars qw/ $n /;    # nom de la palette ie: -n="namePalette"
use vars qw/ $c /;    # nombre de columns a presenter -c=6
use vars qw/ $m /;    # tri selon modele rgb ou hsv -m="rgb"|"hsv"
use vars qw/ $k /
  ;    # cle de tri 0|1|2 correspond [r|g|b] ou[h|s|v] -k=0 red ou hue
use vars qw/ $s /;    # sens du tri ascendant = 0 ou descendant = 1 -s="0|1"
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
);
print "\n  ⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺\n";
print "       Iｔ'ｓ 𝒂     \n", "         ★   ★      \n",
  "       K I W I      \n     ｓｃｒｉｐｔ  ✔ \n";
print "  ⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽\n";
print
  "\nProgramme de création d'une palette .gpl à partir d'un fichier css\n";
print "version: $version\n";

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Simule un modulo
# usage: m*remainder(x,m) <=> (x)modulo(m)
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub remainder {
    my ( $a, $b ) = @_;
    return 0 unless $b && $a;
    return $a / $b - int( $a / $b );
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Ouvre en lecture le fichier CSS à analyser
# param: nom du fichier
# return:
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub loadFileCss {
    my $f = shift @_;
    print "\nRecherche le fichier: " . basename($f) . "\n" if defined $f;
    if ( defined $f ) {
        open( $fCss, "<", $f )
          or die "Echec ouverture du fichier $f : $!";
        print "\nOuverture du fichier $f";
    }
    else { die "Nom du fichier css inconnu." }

}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Ouvre en ecriture le fichier GPL a crèer et ecrit l'en tête GPL
# param: nom du fichier .gpl à creer
# param: fichier css source
# return:
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub writeHeaderFileGpl {
    my ( $f, $css ) = @_;
    my $NoExt = '(.+?)(\.[^\.]*+$|$)'; #suppr toute extension (.+?)(\.[^\.]+$|$)
    if ( defined $f ) {
        unless ( $f =~ /^(\w+)/ ) { $f = $css; }
        if ( defined( $f =~ /$NoExt/ ) && length($f) != 0 ) {
            die
"Le fichier $1.gpl existe. Choisir une autre nom ou le supprimer\n"
              if -e "$1.gpl";
            open( $fGpl, ">", $1 . ".gpl" )
              or die "Echec ecriture du fichier : $1.gpl!";
            $n = $1 unless defined $n;
        }
        else { die "Echec ecriture du fichier gpl"; }
    }
    else {
        if ( $css =~ /$NoExt/ ) {
            die
"Le fichier $1.gpl existe. Choisir une autre nom ou le supprimer\n"
              if -e "$1.gpl";
            open( $fGpl, ">", $1 . ".gpl" )
              or die "Echec ecriture du fichier : $1.gpl!";
            $n = $1 unless defined $n;
        }
        else { die "Echec ecriture du fichier gpl"; }
    }
    $n =~ s/^\s+|\s+$//g if defined $n;
    if   ( defined $c ) { $c = 1 unless ( $c =~ /^\d+$/ ) }
    else                { $c = 1; }
    my $datestring = localtime();
    $c .= "\n" . "#\n# Initial file: $css" . "\n" . "# Create: $datestring";
    printf( "${Header}", $n, $c );    # sortie ecran
    return my $success = printf( $fGpl "${Header}", $n, $c );
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Ouvre en ecriture le fichier GPL ecrit le body
# param: nom du fichier
# return: succes de l'ecriture
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub writeBodyFileGpl {
    my ( $f, $css ) = @_;
    my $NoExt = '(.+?)(\.[^\.]*+$|$)'; #suppr toute extension (.+?)(\.[^\.]+$|$)
    if ( defined $f ) {
        unless ( $f =~ /^(\w+)/ ) { $f = $css; }
        if ( defined( $f =~ /$NoExt/ ) && length($f) != 0 ) {
            open( $fGpl, ">>", $1 . ".gpl" )
              or die "Echec ecriture du fichier : $1.gpl!";
        }
    }
    else {
        if ( $css =~ /$NoExt/ ) {
            open( $fGpl, ">>", $1 . ".gpl" )
              or die "Echec ecriture du fichier : $1.gpl!";
        }
        else { die "Echec ecriture du fichier gpl"; }
    }
    print($Body );    #sortie ecran
    return my $success = print $fGpl $Body;
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Ouvre en lecture le fichier CSS à analyser
# param: nom du fichier
# return: à l'ecran (version alpha) les couleurs et commentaire format GPL
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub readFileCss {
    my $f = shift @_;
    my $l = "";
    open( $fCss, "<", $f ) or die "Echec ouverture du fichier css : $!";
    while ( defined( $l = <$fCss> ) ) {
        chomp $l;

        # if ( extractHexa($l) ne '' ) {
        #     $Body .=
        #       doLineGpl( hexa2rgb( extractHexa($l) ), extractComment($l) )
        #       . "\n";
        # }
        my @hexaList = extractHexaList($l);

        # print "hexaList", @hexaList, "\n";
        if (@hexaList) {
            foreach (@hexaList) {
                $Body .= doLineGpl( hexa2rgb($_), extractComment($l) ) . "\n";
            }
        }
        if ( extractRgbHsl($l) ne '' ) {
            $Body .= doLineGpl( extractRgbHsl($l), extractComment($l) ) . "\n";
        }
        my @colorNameRgb = extractColorNamed($l);
        if (@colorNameRgb) {
            foreach my $rgb (@colorNameRgb) {
                $Body .= doLineGpl( $rgb, extractComment($l) ) . "\n";
            }
        }
    }
    my @sBody = split( "\n", $Body );
    my %hashBody; # hash pour dedoublonner sur clé  (never mind about comments)
    foreach my $s (@sBody) {
        for ($s) {
            s/^\s+//;     # supprime les blancs au début
            s/\s+$//;     # supprime les blancs à la fin
            s/\s+/ /g;    # minimise les blancs internes
        }

        #print "\nligne ", $s;
        if ( $s =~ m/^(\s*\d{1,3}\s+\d{1,3}\s+\d{1,3}\s+)(.*)$/g ) {
            $hashBody{$1} = $1 . $2;    #cle est la valeur <r g b>
        }
    }
    $Body = "";
    $m    = "rgb" unless defined $m;
    $k    = "0" unless defined $k;
    $s    = "0" unless defined $s;
    print "\navant requete:\n";
    say Dumper %hashBody;
    sortQuery( \%hashBody, "hsv", $k, $s )
      ;    ### $m,$k,$s DEBUG  DEBUG  DEBUG  DEBUG  DEBUG  DEBUG
    return $Body;
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Tri la hash table des lignes du fichier selon la requete
# param:
# return:
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub sortQuery {

    # print @_;
    my %hashLine = %{ shift() };
    my $model    = shift @_;    # parametre modele de tri rgb ou hsv
    my $clef     = shift @_;    # critere de tri sur r/g/b ou bien h/s/v (0,1,2)
    my $order = shift @_;    # sens du tri 0 ou 1 soit ascendant ou descendant
    my %sort;
    say Dumper %hashLine;
    say Dumper $model;
    say Dumper $clef;
    say Dumper $order;

    if ( $model eq "hsv" ) {
        foreach ( values %hashLine ) {
            my ( $h, $s, $v ) = rgb2hsv( split " ", $_ );
            $sort{ $h . " " . $s . " " . $v } = $_;
        }
        my @keySort       = keys %sort;
        my @dataKeySorted = sortHsv( \@keySort, $clef, $order );
        say Dumper @dataKeySorted;
        exit 0;
        return @sort{@dataKeySorted};
    }
    else {    # tri rgb par defaut
        if ( $order == "1" ) {
            foreach my $key ( reverse sort keys %hashLine ) {
                my $Line .= $hashLine{$key} . "\n";
            }
        }
        else {
            foreach my $key ( sort keys %hashLine ) {
                my $Line .= $hashLine{$key} . "\n";
            }
        }
    }
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Extrait du fichier CSS le commentaire de la ligne et le formate GPL
# param: ligne en cours du fichier CSS
# return: le commentaire format GPL
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub extractComment {
    my $line           = shift @_;
    my $patternComment = ';\s*\/\*(.*)\*\/';  #extrait commentaire bout de ligne
    if ( $line =~ /$patternComment/ ) {
        my $cmt = $1;
        $cmt =~ s/^\s+|\s+$//g;               #trim: left and right
        $cmt =~ s/((\*\/)|(\/\*))\s*//g;      #suppr: espace*/espace/*espace
        return $cmt;
    }
    return "";
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Extrait du fichier CSS le format #hexa[3 ou 6]
# param: ligne en cours du fichier CSS
# return: le format hexa de la couleur <ABCDEF> ou <ABC>
# /!\ CSS4 #ff00ffaa | #f0fa ->canal alpha en hexa non implementé /!\
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub extractHexa {
    my $line    = shift @_;
    my $pattern = "#([a-fA-F0-9]{6})|#([a-fA-F0-9]{3})";  # code #ABCDEF ou #ABC
    my $match   = "";

    if ( $line =~ /$pattern/g ) {
        $match = defined $1 ? $1 : $2;
    }
    return $match;
}

# version List
sub extractHexaList {
    my $line    = shift @_;
    my $pattern = "#([a-fA-F0-9]{6})|#([a-fA-F0-9]{3})";  # code #ABCDEF ou #ABC
    my @r       = ();
    if ( my @hexa = ( $line =~ /$pattern/g ) ) {
        foreach (@hexa) { push @r, $_ if defined $_ }
        return @r;
    }
    return @r;
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Extrait du fichier CSS une couleur nommée
# param: ligne en cours du fichier CSS
# return: le format gpl de la couleur ou une liste couleur (cas des gradient)
# /!\ il y' a plus de 140 couleurs nommées car grey=gray => 148 couleurs     /!\
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub extractColorNamed {
    my $line = shift @_;
    my @rgb  = ();

    #my @key = keys(%IDlistNameColor);
    foreach my $colorName ( keys(%IDlistNameColor) ) {
        if ( my $test = ( $line =~ /:.*(?:\s*|,|:)\b($colorName)\b.*;/i )
          )    #capture que le dernier
        {
            push @rgb, colorName2rgb($colorName);
        }
    }
    return @rgb;
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
sub extractRgbHsl {
    my $line = shift @_;
    my $patternStrictRgb =
      '(rgb)a?\(\s*(\d{1,3})%\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%.*\)';
    my $patternStrictHsl =
'(?:hsl)a?\(\s*(\d*?\.?\d*)(deg|grad|rad|turn)\s*,\s*(\d{1,3})%\s*,\s*(\d{1,3})%.*\)';

# admet les pourcentage decimaux, sans unite d'angle (degre par defaut) et l'expression sans virgule separatrice:
# (?:hsl)a?\(\s*(\d*?\.?\d*)(deg|grad|rad|turn|)?\s*,?\s*(\d*\.?\d*)%\s*,?\s*(\d*\.?\d*)%
# A TESTER
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
        my ( $t, $r, $g, $b ) = ( $1, $2 * 2.55, $3 * 2.55, $4 * 2.55 );
        $sRgb = sprintf( "%3.f %3.f %3.f", $r, $g, $b );    #arrondi float
        $sRgb =~ s/^\s+|\s+$//g;
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
        else {    # degré par defaut
            $h = 360 * remainder( $h, 360.0 );
        }
        $sRgb = hsl2Rgb( $h, $s, $l );
        $sRgb =~ s/^\s+|\s+$//g;
        return $sRgb;
    }

    if ( $line =~ /$patternRgbHsl/ ) {
        my ( $t, $r, $g, $b ) = ( $1, $2, $3, $4 );
        if ( $t =~ /rgb/ ) {
            $sRgb = sprintf( "%3d %3d %3d", $r, $g, $b );
        }
        elsif ( $t =~ /hsl/ ) {    # les positions r g b correspond h s l
            $sRgb = hsl2Rgb( $r, $g, $b );

        }
        $sRgb =~ s/^\s+|\s+$//g;
        return $sRgb;
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
    my $sRgb = sprintf( "%3.f %3.f %3.f", $r, $g, $b );    #arrondi float
    $sRgb =~ s/^\s+|\s+$//g;
    return $sRgb;
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

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Conversion valeurs hexadecimales to RGB
# param: code hexadecimal de la couleur
# return: le format GPL de la couleur
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub hexa2rgb {
    my $hexa = shift @_;
    my @rgb;
    my $sRgb;
    if ( length($hexa) == 6 ) {
        push @rgb, substr( $hexa, 0, 2 ), substr( $hexa, 2, 2 ),
          substr( $hexa, 4, 2 );

        #debug BEGIN
        # test s//eg  TEST OK!
        # $hexa =~ s/([[:xdigit:]]{2})/sprintf "%03d ",hex $1/eg ;
        # $hexa =~ s/^\s+|\s+$//g ;
        # print "\ntest : |", $hexa , "|" ;
        #debug END
    }
    elsif ( length($hexa) == 3 ) {
        push @rgb, substr( $hexa, 0, 1 ) x 2, substr( $hexa, 1, 1 ) x 2,
          substr( $hexa, 2, 1 ) x 2;

        #print "\nhexa2rgb 3 digit ", $rgb[0] . " " . $rgb[1] . " " . $rgb[2] ;
    }
    else { return $sRgb; }
    foreach (@rgb) {
        $sRgb .= sprintf( "%03d ", hex $_ );
    }
    $sRgb =~ s/^\s+|\s+$//g;    #trim blanc debut et final
    return $sRgb;
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Converti le rgb format gpl en hexa pour l'inclure dans le commentaire
# param: le color rgb 255 255 255 format gpl
# return: en format hexa ABCDEF
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub rgb2hexa {
    my $rgb = shift @_;
    $rgb =~ s/(?:0{0,2})(\d+)/$1/g
      ; # enleve les 1 ou 2 zero debut de chaque r g b, ie: 009 -> 9 | 080 -> 80 | 125 ->125
    my ( $r, $g, $b ) = split /\s+/, $rgb;
    my $hexa =
      sprintf( "\%2.2X\%2.2X\%2.2X", $r, $g, $b );    #3x2digits complete par 0
    return $hexa;
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Converti rgb en hsv (HSV Hue Saturation Value ou  TSV Teinte Saturation Valeur)
# Pour faire un tri sur h,s ou v
# param: le color rgb 255 255 255 format gpl
# return: une liste (h,s,v)
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
    print "\nresult : \n";
    say Dumper @result;
    return @result;

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
    my $hsvList = shift @_;
    say Dumper $hsvList;

    # exit 0;
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

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Converti "$key<les couleurs nommées>"=>"$value<code hexa>" au format rgb de gpl
# param: la couleur nommées $key de %ColorComment
# return: en format gpl $R[0..255] $G[0..255] $B[0..255] ie: 000 255 068
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub colorName2rgb {
    my $colorName = shift @_;
    my @rgb       = $IDlistNameColor{ lc $colorName } =~
      /([0-9A-Fa-f]{2})/g;    # ABCDEF->('AB','CD','EF')
    my $sRgb;
    foreach (@rgb) {
        $sRgb .=
          sprintf( "%03d ", hex $_ );    #force en hexa et converti en decimal
    }
    $sRgb =~ s/\s$//g;                   #trim blanc final
    return $sRgb;
}

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Fait la ligne gpl au format <R(0..255)> <G(0..255)> <B(0..255)> <#codeHexa [color named] [comments]>
# param: liste couleur au format + le commentaire extrait
# + le code hexa dans les commentaires n'est pas obligatoire, c'est pour aider
#   l'utilisateur de la palette dans GIMP
# Ecrit dans la hash table $keys= couleur au format $value= commentaire extrait
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sub doLineGpl {
    my ( $color, $comment ) = @_;
    $color =~ s/(?:0{0,2})(\d+)\s*/ $1/g; #attention à garder l'espace avant $1
    $color =~ s/^\s+|\s+$//g;

    #enleve les 0 en trop (pour la conversion en hexa)
    unless ( exists( $ColorComment{$color} ) ) {
        $ColorComment{$color} = rgb2hexa($color) . " " . $comment;
    }
    else {
        $ColorComment{$color} .= " " . $comment;
    }
    my ( $r, $g, $b ) =
      split( /\s+/, $color );             #recupere les r g b sur les espaces
    my %rIDlistNameColor = reverse %IDlistNameColor;
    if ( exists( $rIDlistNameColor{ rgb2hexa($color) } ) ) {
        ( my $lineGpl = $ColorComment{$color} ) =~
s/([[:xdigit:]]{6})\s(.*)/sprintf "%3d %3d %3d %s %-20s %-48.48s", $r, $g, $b, $1, $rIDlistNameColor{ rgb2hexa($color) },$2/eg;
        return $lineGpl;
    }
    else {
        return (
            sprintf( "%3d %3d %3d ", $r, $g, $b ) . $ColorComment{$color} );
    }
}

#  ___________________________________________________________________________
# |                                                                           |
# |                         </{Version β 1.0}>     (°}<Ouais!                 |
# |___________________________________________________________________________|
my $File    = $i;    # recupere 1er argument
my $FileGpl = $o;    # recupere 2e argument

loadFileCss($File);
readFileCss($File);
print "\nEcriture du fichier gpl (en tête)"
  if writeHeaderFileGpl( $FileGpl, $File );
print "\nEcriture du fichier gpl (données)"
  if writeBodyFileGpl( $FileGpl, $File );
print "\n";
