pragma solidity 0.4.24;

import "bancor-contracts/solidity/contracts/converter/BancorConverter.sol";
import "bancor-contracts/solidity/contracts/token/SmartToken.sol";
import "bancor-contracts/solidity/contracts/token/EtherToken.sol";
import "bancor-contracts/solidity/contracts/token/interfaces/IERC20Token.sol";

///@title A contract for converting any token into MYB (using Bancor's API)
///@author Vlad Silviu Farcas
contract TokenConverter {

    address bancorConverterAddress;   
    address myBitTokenContractAddress;
    BancorConverter converter; 

    ///@notice initialise addresses needed for conversion
    constructor(
        address _bancorConverterAddress, 
        address _myBitTokenContractAddress
        ) {
        bancorConverterAddress = _bancorConverterAddress;
        myBitTokenContractAddress = _myBitTokenContractAddress;
        converter = BancorConverter(bancorConverterAddress);
    }

    ///@notice convert some tokens
    ///@param _token the contract of the token that is about to be converted
    ///@param _amount the amount of _token that is about to be converted
    ///@param _minimumReturn the minimum return of MyBit token that is about to be received
    function convertTokenToMyBit(
        address _token, 
        uint _amount, 
        uint _minimumReturn
        ) external payable{
        IERC20Token token;
        SmartToken myBit = SmartToken(myBitTokenContractAddress);
        uint amount = _amount;
        if (msg.value == 0){
            token = SmartToken(_token);
            token.transferFrom(msg.sender, this, amount);
            token.approve(bancorConverterAddress, amount); 
        } else {
            token = EtherToken(_token);
            amount = msg.value;
        }
        
        uint convertedValue = converter.convert(
            token, 
            myBit,
            amount,
            _minimumReturn
        );
        require (convertedValue >= _minimumReturn, "Transaction failed.");
        myBit.transfer(msg.sender, convertedValue);
    }

}