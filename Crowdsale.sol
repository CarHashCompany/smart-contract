pragma solidity ^0.4.23;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./MintableToken.sol";


/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract Crowdsale is Ownable {
  using SafeMath for uint256;

 // The token being sold
    MintableToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public ICOStartTime;
    uint256 public ICOEndTime;

    // wallet address where funds will be saved
    address internal wallet;

    // amount of raised money in wei
    uint256 public weiRaised; // internal

    // Public Supply
    uint256 public publicSupply;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // CarHash Crowdsale constructor
    constructor(MintableToken _token, uint256 _publicSupply, uint256 _startTime, uint256 _endTime, address _wallet) public {
        require(_endTime >= _startTime);
        require(_wallet != 0x0);

        //CarHash token creation
        token = _token;

        // total supply of token for the crowdsale
        publicSupply = _publicSupply;

        // Pre-ICO start Time
        ICOStartTime = _startTime;

        // ICO end Time
        ICOEndTime = _endTime;

        // wallet where funds will be saved
        wallet = _wallet;
        
    }

    // fallback function can be used to buy tokens
    function() public payable {
        buyTokens(msg.sender);
    }

    // High level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        // minimum investment should be 0.85 ETH
        uint256 lowerPurchaseLimit = 0.85 ether;
        require(msg.value >= lowerPurchaseLimit);

        assert(_tokenPurchased(msg.sender, beneficiary, msg.value));

        // update state
        weiRaised = weiRaised.add(msg.value);

        forwardFunds();
    }

    function _tokenPurchased(address /* buyer */, address /* beneficiary */, uint256 /* weiAmount */) internal returns (bool) {
        // TO BE OVERLOADED IN SUBCLASSES
        return true;
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = ICOStartTime <= now && now <= ICOEndTime;
        bool nonZeroPurchase = msg.value != 0;

        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > ICOEndTime;
    }
bool public checkBurnTokens = false;

    function burnTokens() onlyOwner public returns (bool) {
        require(hasEnded());
        require(!checkBurnTokens);

        token.mint(0x0, publicSupply);
       
        publicSupply = 0;
        checkBurnTokens = true;

        return true;
    }

    function getTokenAddress() onlyOwner public view returns (address) {
        return address(token);
}
}