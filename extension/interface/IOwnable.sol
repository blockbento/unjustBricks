// SPDX-License-Identifier: Apache-2.0
/**
 *   __  __     __   __       __     __  __     ______     ______      ______     ______     __     ______     __  __     ______    
 *  /\ \/\ \   /\ "-.\ \     /\ \   /\ \/\ \   /\  ___\   /\__  _\    /\  == \   /\  == \   /\ \   /\  ___\   /\ \/ /    /\  ___\   
 *  \ \ \_\ \  \ \ \-.  \   _\_\ \  \ \ \_\ \  \ \___  \  \/_/\ \/    \ \  __<   \ \  __<   \ \ \  \ \ \____  \ \  _"-.  \ \___  \  
 *   \ \_____\  \ \_\\"\_\ /\_____\  \ \_____\  \/\_____\    \ \_\     \ \_____\  \ \_\ \_\  \ \_\  \ \_____\  \ \_\ \_\  \/\_____\ 
 *    \/_____/   \/_/ \/_/ \/_____/   \/_____/   \/_____/     \/_/      \/_____/   \/_/ /_/   \/_/   \/_____/   \/_/\/_/   \/_____/ 
 *
 * @title   Ownable
 * @author  blockbento
 * @notice  Thirdweb's `Ownable` is a contract extension to be used with any base contract. It exposes functions for setting and reading
 *          who the 'owner' of the inheriting smart contract is, and lets the inheriting contract perform conditional logic that uses
 *          information about who the contract's owner is.
*/

pragma solidity ^0.8.0;

/**
 *  Thirdweb's `Ownable` is a contract extension to be used with any base contract. It exposes functions for setting and reading
 *  who the 'owner' of the inheriting smart contract is, and lets the inheriting contract perform conditional logic that uses
 *  information about who the contract's owner is.
 */

interface IOwnable {
    /// @dev Returns the owner of the contract.
    function owner() external view returns (address);

    /// @dev Lets a module admin set a new owner for the contract. The new owner must be a module admin.
    function setOwner(address _newOwner) external;

    /// @dev Emitted when a new Owner is set.
    event OwnerUpdated(address indexed prevOwner, address indexed newOwner);
}