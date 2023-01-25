// SPDX-License-Identifier: Apache-2.0
/**
 *   __  __     __   __       __     __  __     ______     ______      ______     ______     __     ______     __  __     ______    
 *  /\ \/\ \   /\ "-.\ \     /\ \   /\ \/\ \   /\  ___\   /\__  _\    /\  == \   /\  == \   /\ \   /\  ___\   /\ \/ /    /\  ___\   
 *  \ \ \_\ \  \ \ \-.  \   _\_\ \  \ \ \_\ \  \ \___  \  \/_/\ \/    \ \  __<   \ \  __<   \ \ \  \ \ \____  \ \  _"-.  \ \___  \  
 *   \ \_____\  \ \_\\"\_\ /\_____\  \ \_____\  \/\_____\    \ \_\     \ \_____\  \ \_\ \_\  \ \_\  \ \_____\  \ \_\ \_\  \/\_____\ 
 *    \/_____/   \/_/ \/_/ \/_____/   \/_____/   \/_____/     \/_/      \/_____/   \/_/ /_/   \/_/   \/_____/   \/_/\/_/   \/_____/ 
 *
 * @title   unjustBricks
 * @author  blockbento
 * @notice  
*/                                                                                                  

pragma solidity ^0.8.11;

// ---------- External Imports ----------
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";


import "./ERC721Wrapper.sol";

contract unjustBricks is ERC721Wrapper, ERC2981, Ownable {
    string public baseURI;

    constructor(
        address justBricksAddr,
        string memory initialBaseURI,
        address payable royaltiesReceiver
    ) ERC721Wrapper("unjustBricks", "UNJUSTBRICKS", justBricksAddr) {
        baseURI = initialBaseURI;
        setRoyaltyInfo(royaltiesReceiver, 0);       
    }

    // Accessors

  function setBaseURI(string calldata uri) public onlyOwner {
    baseURI = uri;
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  // Wraps

  function wrap(uint256 id) public {
    _wrap(id);
  }

  function unwrap(uint256 id) public {
    _unwrap(id);
  }

  function exists(uint256 id) public view returns (bool) {
    return _exists(id);
  }

  function rescueBrick(uint256 id, address destination) public onlyOwner {
    collection.safeTransferFrom(address(this), destination, id);
  }

  // IERC2981

  function setRoyaltyInfo(address payable receiver, uint96 numerator) public onlyOwner {
    _setDefaultRoyalty(receiver, numerator);
  }

  // ERC165

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
    return ERC721.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
  }
}