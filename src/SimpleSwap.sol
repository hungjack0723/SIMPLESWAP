// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestERC20.sol";

contract SimpleSwap {
  // phase 1
  TestERC20 public token0;
  TestERC20 public token1;

  // phase 2
  uint256 public totalSupply = 0;
  mapping(address => uint256) public share;

  constructor(address _token0, address _token1) {
    token0 = TestERC20(_token0);
    token1 = TestERC20(_token1);
  }

  function swap(address _tokenIn, uint256 _amountIn) public {
    if (_tokenIn == address(token0)) { // address(token0) is the same as token0
      token0.transferFrom(msg.sender, address(this), _amountIn); 
      token1.transfer(msg.sender, _amountIn);
    } else if (_tokenIn == address(token1)) {
      token1.transferFrom(msg.sender, address(this), _amountIn);
      token0.transfer(msg.sender, _amountIn);
    } else {
      revert("SimpleSwap: invalid token");
    }
  }

  function swap2(address _tokenIn, uint256 _amountIn) public {
    uint256 amountOut = (_amountIn * 3) + 10000;
    if (_tokenIn == address(token0)) { // address(token0) is the same as token0
      token0.transferFrom(msg.sender, address(this), _amountIn); 
      token1.transfer(msg.sender, amountOut);
    } else if (_tokenIn == address(token1)) {
      token1.transferFrom(msg.sender, address(this), _amountIn);
      token0.transfer(msg.sender, amountOut);
    } else {
      revert("SimpleSwap: invalid token");
    }
  }

  // phase 1
  function addLiquidity1(uint256 _amount) public {
    token0.transferFrom(msg.sender, address(this), _amount);
    token1.transferFrom(msg.sender, address(this), _amount);
  }

  function removeLiquidity1() public {
    uint256 _amount = token0.balanceOf(address(this));
    token0.transfer(msg.sender, _amount);
    _amount = token1.balanceOf(address(this));
    token1.transfer(msg.sender, _amount);
  }

  // phase 2
  function addLiquidity2(uint256 _amount) public {
    uint256 _share = totalSupply == 0 ? _amount : _amount * totalSupply / token0.balanceOf(address(this));
    token0.transferFrom(msg.sender, address(this), _amount);
    token1.transferFrom(msg.sender, address(this), _amount);
    totalSupply += _share;
    share[msg.sender] += _share;
  }

  function removeLiquidity2() public {
    uint256 _share = share[msg.sender];
    uint256 _amount0 = token0.balanceOf(address(this)) * _share / totalSupply;
    uint256 _amount1 = token1.balanceOf(address(this)) * _share / totalSupply;
    totalSupply -= _share;
    share[msg.sender] = 0;
    token0.transfer(msg.sender, _amount0);
    token1.transfer(msg.sender, _amount1);
  }
}