pragma solidity 0.4.24;

import "bancor-contracts/solidity/contracts/BancorNetwork.sol";
import "bancor-contracts/solidity/contracts/token/EtherToken.sol";
import "bancor-contracts/solidity/contracts/token/interfaces/IERC20Token.sol";
import "bancor-contracts/solidity/contracts/token/SmartToken.sol";


///@title A contract for converting any token into MYB (using Bancor's API)
///@author Vlad Silviu Farcas
contract TokenConverter {

    BancorNetwork bancorNetwork;

    ///@notice initialise addresses needed for conversion
    constructor() {
        bancorNetwork = BancorNetwork(0xF20b9e713A33F61fA38792d2aFaF1cD30339126A);
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
        IERC20Token[] memory path = new IERC20Token[](3);
        SmartToken myBit = SmartToken(0x5d60d8d7eF6d37E16EBABc324de3bE57f135e0BC); 
        uint amount = _amount;
        uint value = 0;
        if (msg.value == 0){
            require(bancorNetwork.etherTokens(_token) == true, "Token not supported");
            token = SmartToken(_token);
            token.transferFrom(msg.sender, this, amount);
            token.approve(bancorNetwork, amount); 
        } else {
            token = EtherToken(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
            amount = msg.value;
            value = msg.value;
        }
        path[0] = token;
        path[1] = myBit;
        path[2] = myBit;
        require (myBit.balanceOf(this) == 0, "Residual MyBit tokens found.");
        uint convertedValue = bancorNetwork.convert.value(value)(
            path,
            amount,
            _minimumReturn
        );
        require (convertedValue >= _minimumReturn, "Transaction failed.");
        require (myBit.balanceOf(this) == convertedValue, "Transaction failed with different return than expected.");
        require (token.balanceOf(this) <= amount, "Transaction failed without conversion.");
        myBit.transfer(msg.sender, convertedValue);
        token.transfer(msg.sender, token.balanceOf(this));
    }

}