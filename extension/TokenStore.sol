// SPDX-License-Identifier: Apache-2.0
/**
 *   __  __     __   __       __     __  __     ______     ______      ______     ______     __     ______     __  __     ______    
 *  /\ \/\ \   /\ "-.\ \     /\ \   /\ \/\ \   /\  ___\   /\__  _\    /\  == \   /\  == \   /\ \   /\  ___\   /\ \/ /    /\  ___\   
 *  \ \ \_\ \  \ \ \-.  \   _\_\ \  \ \ \_\ \  \ \___  \  \/_/\ \/    \ \  __<   \ \  __<   \ \ \  \ \ \____  \ \  _"-.  \ \___  \  
 *   \ \_____\  \ \_\\"\_\ /\_____\  \ \_____\  \/\_____\    \ \_\     \ \_____\  \ \_\ \_\  \ \_\  \ \_____\  \ \_\ \_\  \/\_____\ 
 *    \/_____/   \/_/ \/_/ \/_____/   \/_____/   \/_____/     \/_/      \/_____/   \/_/ /_/   \/_/   \/_____/   \/_/\/_/   \/_____/ 
 *
 * @title   Token Store
 * @author  blockbento
 * @notice  `TokenStore` contract extension allows bundling-up of ERC20/ERC721/ERC1155 and native-tokan assets
 *          and provides logic for storing, releasing, and transferring them from the extending contract.
 *
 * @dev     See {CurrencyTransferLib}
*/

pragma solidity ^0.8.0;

//  ==========  External imports    ==========

import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

//  ==========  Internal imports    ==========

import { TokenBundle, ITokenBundle } from "./TokenBundle.sol";
import "lib/CurrencyTransferLib.sol";

/**
 *  @title   Token Store
 *  @notice  `TokenStore` contract extension allows bundling-up of ERC20/ERC721/ERC1155 and native-tokan assets
 *           and provides logic for storing, releasing, and transferring them from the extending contract.
 *  @dev     See {CurrencyTransferLib}
 */

contract TokenStore is TokenBundle, ERC721Holder, ERC1155Holder {
    /// @dev The address of the native token wrapper contract.
    address internal immutable nativeTokenWrapper;

    constructor(address _nativeTokenWrapper) {
        nativeTokenWrapper = _nativeTokenWrapper;
    }

    /// @dev Store / escrow multiple ERC1155, ERC721, ERC20 tokens.
    function _storeTokens(
        address _tokenOwner,
        Token[] calldata _tokens,
        string memory _uriForTokens,
        uint256 _idForTokens
    ) internal {
        _createBundle(_tokens, _idForTokens);
        _setUriOfBundle(_uriForTokens, _idForTokens);
        _transferTokenBatch(_tokenOwner, address(this), _tokens);
    }

    /// @dev Release stored / escrowed ERC1155, ERC721, ERC20 tokens.
    function _releaseTokens(address _recipient, uint256 _idForContent) internal {
        uint256 count = getTokenCountOfBundle(_idForContent);
        Token[] memory tokensToRelease = new Token[](count);

        for (uint256 i = 0; i < count; i += 1) {
            tokensToRelease[i] = getTokenOfBundle(_idForContent, i);
        }

        _deleteBundle(_idForContent);

        _transferTokenBatch(address(this), _recipient, tokensToRelease);
    }

    /// @dev Transfers an arbitrary ERC20 / ERC721 / ERC1155 token.
    function _transferToken(
        address _from,
        address _to,
        Token memory _token
    ) internal {
        if (_token.tokenType == TokenType.ERC20) {
            CurrencyTransferLib.transferCurrencyWithWrapper(
                _token.assetContract,
                _from,
                _to,
                _token.totalAmount,
                nativeTokenWrapper
            );
        } else if (_token.tokenType == TokenType.ERC721) {
            IERC721(_token.assetContract).safeTransferFrom(_from, _to, _token.tokenId);
        } else if (_token.tokenType == TokenType.ERC1155) {
            IERC1155(_token.assetContract).safeTransferFrom(_from, _to, _token.tokenId, _token.totalAmount, "");
        }
    }

    /// @dev Transfers multiple arbitrary ERC20 / ERC721 / ERC1155 tokens.
    function _transferTokenBatch(
        address _from,
        address _to,
        Token[] memory _tokens
    ) internal {
        uint256 nativeTokenValue;
        for (uint256 i = 0; i < _tokens.length; i += 1) {
            if (_tokens[i].assetContract == CurrencyTransferLib.NATIVE_TOKEN && _to == address(this)) {
                nativeTokenValue += _tokens[i].totalAmount;
            } else {
                _transferToken(_from, _to, _tokens[i]);
            }
        }
        if (nativeTokenValue != 0) {
            Token memory _nativeToken = Token({
                assetContract: CurrencyTransferLib.NATIVE_TOKEN,
                tokenType: ITokenBundle.TokenType.ERC20,
                tokenId: 0,
                totalAmount: nativeTokenValue
            });
            _transferToken(_from, _to, _nativeToken);
        }
    }
}