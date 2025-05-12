// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Utils } from "./Utils.sol";


/// @title
library OwnsRenderer {
    /// @notice Number of grid columns
    uint256 private constant _COLS = 4;      

    /// @notice Number of rows in grid
    uint256 private constant _ROWS = 6;      

    /// @notice Horizontal offset when duplicating columns
    uint256 private constant _UNDERLINE_OFFSET_X = 103;      

    /// @notice Vertical offset when duplicating rows
    uint256 private constant _UNDERLINE_OFFSET_Y = 24;    

    /// @notice Offset in X direction from index number to start drawing word
    uint256 private constant _LETTERS_START_OFFSET_X = 10;      


    struct SVGParams {
        bytes letters;      // Caveat Font (base64)
        bytes digits;       // Inter Font (base64)
        string[] mnemonic;  // Mnemonic of 24 words or less
    }

    /**
     * @notice Generate the complete SVG code for a given Check.
     */
    function _generateSVG(OwnsRenderer.SVGParams memory params) internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg" style="width:100%;background:#fff;">',
                    '<defs>',
                        '<style>',
                            '@font-face{',
                                'font-display: swap;',
                                'font-family: \'Caveat\';',
                                'font-style: normal;',
                                'font-weight: 700;',
                                'src: url(\'data:font/woff2; charset=utf-8; base64,', params.letters, ') format(\'woff2\');',
                            '}',
                            '@font-face{',
                                'font-display: swap;',
                                'font-family: \'Inter\';',
                                'font-style: italic;',
                                'font-weight: 700;',
                                'src: url(\'data:font/woff2; charset=utf-8; base64,', params.digits, ') format(\'woff2\');',
                            '}',
                            '.index {',
                                'font-family: "Inter";',
                                'font-size: 6px;', 
                            '}',
                            '.mnemonic {',
                                'font-family: "Caveat";'
                                'font-size: 18px;', 
                            '}',
                        '</style>',
                        '<path id="path" d="M0 0 83 0" stroke="#000" stroke-width="0.5"/>',
                        _generatePathRow(), 
                    '</defs>',
                    '<rect width="512" height="512" fill="#fff"/>',
                    '<g transform="translate(60, 204)">',
                        _generatePathColumn(),
                        _generateArt(params.mnemonic),
                    '</g>' 
                '</svg>'
            )
        );
    }

    /**
     * @notice Index and mnemonic in place.
     */
    function _generateArt(string[] memory data) internal pure returns (bytes memory) {
        unchecked {
            bytes memory out;
            for (uint256 i = 0; i < _COLS; ++i) {
                uint256 translateX = i * _UNDERLINE_OFFSET_X;
                for (uint256 j = 0; j < _ROWS; ++j) {
                    uint256 translateY = j * _UNDERLINE_OFFSET_Y;
                    uint256 idx = i * _ROWS + j;    

                    out = abi.encodePacked(
                        out,
                        '<text class="index" x="', Utils.uint2str(translateX), '" y="', Utils.uint2str(translateY), '">', 
                            Utils.uint2str(idx + 1),
                        '. </text>',
                        '<text class="mnemonic" x="', Utils.uint2str(translateX + _LETTERS_START_OFFSET_X), '" y="', Utils.uint2str(translateY), '">', 
                            idx < data.length ? data[idx] : '', 
                        '</text>'
                    );
                }
            }
            return out;
        }
    }

    /**
     * @notice Generate the SVG code for the entire 4x6 underline.
     */
    function _generatePathRow() internal pure returns (bytes memory) {
        unchecked {
            bytes memory rowPaths;
            for (uint256 i = 0; i < _COLS; ++i) {
                rowPaths = abi.encodePacked(
                    rowPaths,
                    '<use href="#path" x="', Utils.uint2str(i * _UNDERLINE_OFFSET_X), '" y="0"/>'
                );
            }

            return abi.encodePacked('<g id="row">', rowPaths, '</g>');
        }
    }

    /**
     * @notice Generate the SVG code for the entire 4x6 underline.
     */
    function _generatePathColumn() internal pure returns (bytes memory) {
        unchecked {
            bytes memory colPaths;
            for (uint256 i = 0; i < _ROWS; ++i) {
                colPaths = abi.encodePacked(
                    colPaths,
                    '<use href="#row" y="', Utils.uint2str(i * _UNDERLINE_OFFSET_Y), '"/>'
                );
            }

            return abi.encodePacked('<g id="grid" x="196" y="160">', colPaths, '</g>');
        }
    }
} 
