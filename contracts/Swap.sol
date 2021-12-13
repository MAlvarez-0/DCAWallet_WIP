//SPDX-License-Identifier: UNLICENSED


pragma solidity 0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


//import the uniswap router
//the contract needs to use swapExactTokensForTokens
//this will allow us to import swapExactTokensForTokens into our contract

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(
  
    //amount of tokens we are sending in
    uint256 amountIn,
    //the minimum amount of tokens we want out of the trade
    uint256 amountOutMin,
    //list of token addresses we are going to trade in.  this is necessary to calculate amounts
    address[] calldata path,
    //this is the address we are going to send the output tokens to
    address to,
    //the last time that the trade is valid for
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}




contract Swap {

    address owner; 


    address public constant uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;


    address tokenDAI = 0xaD6D458402F60fD3Bd25163575031ACDce07538D ;
    address tokenSCHN = 0x08866F97bB4FcCacFacD31CbC2d20A566CeD96F1;




    uint public depositedDAI = 0;
    //uint swappedToken = 0;

    constructor() {
        owner = msg.sender;
    }


    modifier isWalletOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }


    //Deposit DAI
    function depositDAI(uint _amount) external isWalletOwner {
        require(IERC20(tokenDAI).transferFrom(msg.sender, address(this), _amount));
        depositedDAI += _amount;
        
    }
    function withdrawDAI(uint _amount) external isWalletOwner {
        require((depositedDAI-_amount) >= 0, "Amount exceed deposited DAI");
        depositedDAI -= _amount;
        IERC20(tokenDAI).transfer(msg.sender, _amount);
    }

    function withdraw(address token, uint _amount) external isWalletOwner {
        IERC20(token).transfer(msg.sender, _amount);
    }
    //////////////


      function swap(uint256 _amountIn) external isWalletOwner {

        uint256 amountOutMin = getAmountOutMin(tokenDAI, tokenSCHN, _amountIn);
        address _to = address(this); 

        IERC20(tokenDAI).approve(uniswapRouter, _amountIn);

        address[] memory path;
          
        path = new address[](2);
        path[0] = tokenDAI;
        path[1] = tokenSCHN;
          

        IUniswapV2Router(uniswapRouter).swapExactTokensForTokens(_amountIn, amountOutMin, path, _to, block.timestamp);
        depositedDAI -= _amountIn;
      }


      function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) internal view returns (uint256) {


        address[] memory path;
        
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        
        
        uint256[] memory amountOutMins = IUniswapV2Router(uniswapRouter).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  

}