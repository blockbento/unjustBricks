// SPDX-License-Identifier: Apache-2.0
/**
 *   __  __     __   __       __     __  __     ______     ______      ______     ______     __     ______     __  __     ______    
 *  /\ \/\ \   /\ "-.\ \     /\ \   /\ \/\ \   /\  ___\   /\__  _\    /\  == \   /\  == \   /\ \   /\  ___\   /\ \/ /    /\  ___\   
 *  \ \ \_\ \  \ \ \-.  \   _\_\ \  \ \ \_\ \  \ \___  \  \/_/\ \/    \ \  __<   \ \  __<   \ \ \  \ \ \____  \ \  _"-.  \ \___  \  
 *   \ \_____\  \ \_\\"\_\ /\_____\  \ \_____\  \/\_____\    \ \_\     \ \_____\  \ \_\ \_\  \ \_\  \ \_____\  \ \_\ \_\  \/\_____\ 
 *    \/_____/   \/_/ \/_/ \/_____/   \/_____/   \/_____/     \/_/      \/_____/   \/_/ /_/   \/_/   \/_____/   \/_/\/_/   \/_____/ 
 *
 * @title   Contract Metadata
 * @author  blockbento
 * @notice  Thirdweb's `ContractMetadata` is a contract extension for any base contracts. It lets you set a metadata URI
 *          for your contract.
 *          Additionally, `ContractMetadata` is necessary for NFT contracts that want royalties to get distributed on OpenSea.
*/

pragma solidity ^0.8.0;

import "./interface/IContractMetadata.sol";

abstract contract Metadata is IContractMetadata {
    /// @notice Returns the contract metadata URI.
    string public override contractURI;

    /**
     *  @notice         Lets a contract admin set the URI for contract-level metadata.
     *  @dev            Caller should be authorized to setup contractURI, e.g. contract admin.
     *                  See {_canSetContractURI}.
     *                  Emits {ContractURIUpdated Event}.
     *
     *  @param _uri     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */

    function setContractURI(string memory _uri) external override {
        if (!_canSetContractURI()) {
            revert("Not authorized");
        }

        _setupContractURI(_uri);
    }

    /// @dev Lets a contract admin set the URI for contract-level metadata.
    function _setupContractURI(string memory _uri) internal {
        string memory prevURI = contractURI;
        contractURI = _uri;

        emit ContractURIUpdated(prevURI, _uri);
    }

    /// @dev Returns whether contract metadata can be set in the given execution context.
    function _canSetContractURI() internal view virtual returns (bool);
}

