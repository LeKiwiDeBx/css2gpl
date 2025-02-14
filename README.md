# CSS Palette Extractor for GIMP

This GIMP plugin extracts colors from CSS stylesheets and creates a palette file (.gpl) without the need for complex conversion calculations. It's a handy tool that significantly reduces manual work.

## Requirements

- The plugin performs parsed actions on CSS stylesheets conforming to CSS3 document rules.
- CSS files must have a .css extension.

## Features

- Parses and converts the following CSS color notations to GPL format:
  - Three-digit (#RGB) and six-digit (#RRGGBB) hex notations
  - rgb(), rgba(), hsl(), and hsla() functional notations
- Merges duplicate colors, preserving the last line comment
- Parses CSS3 color keywords and aliases (e.g., gray/grey)
- Handles color values in different gradient types (linear and radial)
- Ignores opacity values in rgba() and hsla() notations
- Adds six-digit hex values at the beginning of GPL comment lines
- Includes matching color keywords after the hex value in GPL comments
- Preserves CSS comments at the end of GPL lines

## Usage

1. Access the script from GIMP menu: `Palette > Import from CSS...`
2. Fill in the required fields:
   - `File CSS`: Choose the CSS file to extract colors from
   - `File GPL`: Specify the output GPL file name (optional)
   - `Palette name`: Set a name for the palette (optional)
   - `Column number`: Specify the number of columns for the palette (1-10, default: 1)
3. Click OK to generate the GPL file

## Parameters

- `file_css`: Input CSS file path
- `file_gpl`: Output GPL file path
- `name`: Palette name
- `column`: Number of columns (1-10)
- `model`: Color model selection (RGB: 0, HSV: 1)
- `col`: Column ordering (RH: 0, GS: 1, BV: 2)
- `order`: Ascending order toggle (1: enabled, 0: disabled)

## Importing the Generated Palette into GIMP

For instructions on importing the generated color palette into GIMP, please refer to the [GIMP user manual](https://www.gimp.org/docs/).

## Author

Created by </{LeKiwiDeBx}>

For questions or support, please visit the [GitHub repository](https://github.com/LeKiwiDeBx).
