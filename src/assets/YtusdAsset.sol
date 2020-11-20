pragma solidity >=0.5.8 <0.8.0;

import "../interfaces/IERC20.sol";
import "../interfaces/YearnVault.sol";

import "../libraries/SafeMath.sol";
import "../libraries/Address.sol";
import "../libraries/SafeERC20.sol";

import "./BaseElfYVaultAsset.sol";

contract YtusdAsset is BaseElfYVaultAsset {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    constructor(
        address _allocator,
        address _vault,
        address _tusd
    ) public BaseElfYVaultAsset(msg.sender, _allocator, _vault, _tusd) {} // solhint-disable no-empty-blocks
}
