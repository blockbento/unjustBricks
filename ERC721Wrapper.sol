// SPDX-License-Identifier: Apache-2.0
/**
 *   __  __     __   __       __     __  __     ______     ______      ______     ______     __     ______     __  __     ______    
 *  /\ \/\ \   /\ "-.\ \     /\ \   /\ \/\ \   /\  ___\   /\__  _\    /\  == \   /\  == \   /\ \   /\  ___\   /\ \/ /    /\  ___\   
 *  \ \ \_\ \  \ \ \-.  \   _\_\ \  \ \ \_\ \  \ \___  \  \/_/\ \/    \ \  __<   \ \  __<   \ \ \  \ \ \____  \ \  _"-.  \ \___  \  
 *   \ \_____\  \ \_\\"\_\ /\_____\  \ \_____\  \/\_____\    \ \_\     \ \_____\  \ \_\ \_\  \ \_\  \ \_____\  \ \_\ \_\  \/\_____\ 
 *    \/_____/   \/_/ \/_/ \/_____/   \/_____/   \/_____/     \/_/      \/_____/   \/_/ /_/   \/_/   \/_____/   \/_/\/_/   \/_____/ 
 *
 * @title   Wrapper
 * @author  blockbento
 * @notice  
*/                            

pragma solidity ^0.8.11;

// ---------- CORE
// Emnumerable Upgradeable ERC721 contract
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";

// ---------- FEATURES
import "./extension/ContractMetadata.sol";
import "./extension/Royalty.sol";
import "./extension/Ownable.sol";
import "./extension/PermissionsEnumerable.sol";
import { TokenStore, ERC1155Receiver, IERC1155Receiver } from "extension/TokenStore.sol";

contract Multiwrapper is 
  Initializable,
  ContractMetadata,
  Royalty,
  Ownable,
  ERC721Upgradeable, IERC1155ReceiverUpgradeable 



{
  error NotTokenOwnerError();

  IERC721Upgradeable public collection;

  mapping(uint256 => bool) internal _hasBeenWrappedBefore;

  constructor(string memory name, string memory symbol, address collectionAddress) ERC721Upgradeable(name, symbol) {
    collection = IERC721Upgradeable(collectionAddress);
  }

  function _wrap(uint256 id) internal {
    if (collection.ownerOf(id) != _msgSender()) revert NotTokenOwnerError();

    collection.safeTransferFrom(_msgSender(), address(this), id);

    if (_exists(id)) {
      _safeTransfer(address(this), _msgSender(), id, "");
    } else {
      _hasBeenWrappedBefore[id] = true;
      _safeMint(_msgSender(), id);
    }
  }

  function _unwrap(uint256 id) internal {
    if (ownerOf(id) != _msgSender()) revert NotTokenOwnerError();

    _safeTransfer(_msgSender(), address(this), id, "");
    collection.safeTransferFrom(address(this), _msgSender(), id);
  }

  // IERC1155Receiver

  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes memory
  ) public virtual override returns (bytes4) {
    return this.onERC1155Received.selector;
  }
}