// SPDX-License-Identifier:MIT
pragma solidity ^0.8.13; 

// - fetch the swap rate of a pair with uniswap price query method
// - can refer docs 

/// importing uniswap v3-core and v3-periphery 
import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol" ;
import "https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/OracleLibrary.soll" ;


contract UniswapV3 {

    // address of the token pairs and the pool for the same 
    address public immutable token0 ;
    address public immutable token1 ;
    address public immutable pool ;

    constructor(address _factory , address _token0 ,address _token1 ,uint24 _fee) {
        token0 = _token0 ;
        token1 = _token1 ;

        // pool is created using uniswap factory with token addresses and fees
        address  _pool = IUniswapV3Factory(_factory).getPool(
            _token0 ,_token1 ,_fee 
        );

        require(_pool != address(0), "Pool does not exsist") ;

        pool = _pool ;
    }

    /// @dev -  estimate amount out for the tokenIn
    /// @param tokenIn - the address of the token0 we want to supply
    /// @param amountIn -  amount to supply of the token1
    /// @param secondsAgo - how much seconds ago the price we want 
    /// @return amountOut -  the amount out for the 2nd token1
    function estimateAmountOut(
        address tokenIn,
        uint128 amountIn,
        uint32 secondsAgo 
    ) external view returns(uint amountOut) {
        require(tokenIn == token0 || tokenIn == token1 ,"invalid token");
        address tokenOut = token1 == token0 ? token1 : token0 ;

        //  finding the tick in the pool , for a particular timestamp by passing ssecondsAgo from function call
        (int24 tick, ) = OracleLibrary.consult(pool, secondsAgo) ;

        ///calculte amount out at a particular tick
        amountOut = OracleLibrary.getQuoteAtTick(
            tick , amountIn ,tokenIn , tokenOut
        ); 
    
    }
} 