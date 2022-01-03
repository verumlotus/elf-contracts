// SPDX-License-Identifier: Apache-2.0
pragma solidity =0.7.6;

import { OracleLibrary } from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import { IUniswapV3PoolImmutables } from "@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolImmutables.sol";

contract UniswapOracle {
    uint32 internal _twapDuration; // Time range under which price get calculated.
    address internal _pool; // Address of the uniswap v3 pool.
    address internal _baseToken; // Base token.

    /// @notice Initialization of pool and seconds ago that will remain constant through out
    ///         the price query.
    /// @param twapDuration Amount of seconds in which avg tick get calculated.
    ///        It will make the price range [twapDuration, 0], Where 0 tends to latest block.
    /// @param pool Address of Uniswap v3 pool.
    /// @param baseToken Address of the token which will act as the base token for the oracle.
    ///        Ex - ELFI and USDC token pair pool address provided then if `USDC` act as the baseToken
    ///        then this oracle provides 1 USDC = X amount of ELFI tokens as the getPrice() output.
    constructor(
        uint32 twapDuration,
        address pool,
        address baseToken
    ) {
        require(
            _isPoolToken(pool, baseToken),
            "UniswapOracle: Invalid base token"
        );
        _twapDuration = twapDuration;
        _pool = pool;
        _baseToken = baseToken;
    }

    /// @notice Returns the amount of quoteToken anybody can get by providing 1 unit of `baseToken`.
    function getPrice() external view returns (uint256) {
        require(
            OracleLibrary.getOldestObservationSecondsAgo(_pool) >=
                _twapDuration,
            "UniswapOracle: Seconds ago is too early"
        );
        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(
            _pool,
            _twapDuration
        );
        return
            OracleLibrary.getQuoteAtTick(
                arithmeticMeanTick,
                uint128(1),
                _baseToken,
                _getQuoteToken()
            );
    }

    function _isPoolToken(address pool, address targetToken)
        internal
        view
        returns (bool)
    {
        return
            IUniswapV3PoolImmutables(pool).token0() == targetToken ||
            IUniswapV3PoolImmutables(pool).token1() == targetToken;
    }

    function _getQuoteToken() internal view returns (address) {
        return
            IUniswapV3PoolImmutables(_pool).token0() == _baseToken
                ? IUniswapV3PoolImmutables(_pool).token1()
                : IUniswapV3PoolImmutables(_pool).token0();
    }
}
