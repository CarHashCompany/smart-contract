pragma solidity ^0.4.24;
/**
 * @title CarHashToken
 * @author Trust Financial Association "Consent"
**/
import "./SafeMath.sol";
import "./BasicToken.sol";
import "./StandartToken.sol";
import "./Ownable.sol";
import "./MintableToken.sol";
import "./CarHashCrowdsale.sol";
import "./CarHashWhitelist.sol";

contract CarHashToken {
    string public constant name = "CarHashToken";
    string public constant symbol ="CaHaTo";
    uint8 public constant decimals = 18;
    
    uint256 public totalSupply = 100000000;
}
