// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { OwnsRenderer } from "./OwnsRenderer.sol";
import { Utils } from "./Utils.sol";


/// @title
library OwnsMetadata {
    /**
     * @notice Render the JSON Metadata for a given token.
     */
    function tokenURI(uint256 tokenId, OwnsRenderer.SVGParams memory params) internal pure returns (string memory) {
        string memory image = generateSVGImage(params);

        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Owns #', Utils.uint2str(tokenId), '",',
                '"description": "",',
                '"image": "', '"data:image/svg+xml;base64,', image, '",',
                '"attributes": [', attributes(params.mnemonic), ']',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    /**
     * @notice Renders base64-encoded JSON metadata for the specified token.
     */
    function generateSVGImage(OwnsRenderer.SVGParams memory params) internal pure returns (string memory) {
        return Base64.encode(bytes(OwnsRenderer._generateSVG(params)));
    }

    /**
     * @notice Render the JSON atributes for a given token.
     */
    function attributes(string[] memory values) internal pure returns (bytes memory) {
        unchecked {
            string[24] memory traitIndexLabels = [
                "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "ELEVEN",
                "TWELVE", "THIRTEEN", "FOURTEEN", "FIFTEEN", "SIXTEEN", "SEVENTEEN", "EIGHTEEN", 
                "NINETEEN", "TWENTY", "TWENTY-ONE", "TWENTY-TWO", "TWENTY-THREE", "TWENTY-FOUR"
            ];
            bytes memory traits;

            for (uint256 i = 0; i < traitIndexLabels.length; ++i) {
                string memory value = i < values.length 
                    ? values[i] 
                    : "N/A";

                traits = abi.encodePacked(
                    traits,
                    trait(traitIndexLabels[i], value, ',')
                );
            }

            return abi.encodePacked(
                traits,
                ",",
                trait("WORDS", Utils.uint2str(values.length), '')
            );   
        }
    }

    /**
     * @notice Generate the SVG snipped for a single attribute.
     */
    function trait(
        string memory traitType, 
        string memory traitValue, 
        string memory append
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            '{',
                '"trait_type": "', traitType, '",',
                '"value": "', traitValue, '"',
            '}',
            append
        );
    }
}