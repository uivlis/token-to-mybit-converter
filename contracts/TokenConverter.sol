pragma solidity 0.4.24;

import "bancor-contracts/solidity/contracts/IBancorNetwork.sol";
import "bancor-contracts/solidity/contracts/token/interfaces/IEtherToken.sol";
import "bancor-contracts/solidity/contracts/token/interfaces/IERC20Token.sol";
import "bancor-contracts/solidity/contracts/token/interfaces/ISmartToken.sol";


///@title A contract for converting any token into MYB (using Bancor's API)
///@author Vlad Silviu Farcas
contract TokenConverter {

    IBancorNetwork bancorNetwork;

    ///@notice initialise addresses needed for conversion
    constructor() {
        bancorNetwork = IBancorNetwork(0xF20b9e713A33F61fA38792d2aFaF1cD30339126A);
    }

    ///@notice convert some tokens
    ///@param _token the contract of the token that is about to be converted
    ///@param _amount the amount of _token that is about to be converted
    ///@param _minimumReturn the minimum return of MyBit token that is about to be received
    function convertTokenToMyBit(
        address _token, 
        uint _amount, 
        uint _minimumReturn
        ) external payable {
        IERC20Token token;
        IERC20Token[] memory path = new IERC20Token[](5);
        ISmartToken myBit = ISmartToken(0x5d60d8d7eF6d37E16EBABc324de3bE57f135e0BC); 
        ISmartToken bnt = ISmartToken(0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C);
        uint amount = _amount;
        uint value = 0;
        if (msg.value == 0){
            token = ISmartToken(_token);
            token.transferFrom(msg.sender, bancorNetwork, amount);
            token.approve(bancorNetwork, amount); 
        } else {
            token = IEtherToken(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
            amount = msg.value;
            value = msg.value;
        }
        path[0] = token;
        path[1] = bnt;
        path[2] = bnt;
        path[3] = myBit;
        path[4] = myBit;
        uint myBitBalanceBefore = myBit.balanceOf(this);
        uint convertedValue = bancorNetwork.convert.value(value)(
            path,
            amount,
            _minimumReturn
        );
        require(myBit.balanceOf(this) == myBitBalanceBefore + convertedValue, "Transaction failed with return loss.");
        require (convertedValue >= _minimumReturn, "Transaction failed with return below minimum threshold.");
        require (token.balanceOf(this) <= amount, "Transaction failed without conversion.");
        myBit.transfer(msg.sender, convertedValue);
        token.transfer(msg.sender, token.balanceOf(this));
    }

}