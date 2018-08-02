pragma solidity ^0.4.24;

/**
 * @title CarHashCrowdsale
 * @author Trust Financial Association "Consent"
 * @dev CarHashCrowdsale is a base contract for managing the CarHash token crowdsale.
*/

import "./SafeMath.sol";
import "./CarHashToken.sol";
import "./Crowdsale.sol";
import "./CarHashWhitelist.sol";
import "./MintableToken.sol";


contract CarHashCrowdsale {
    uint256 constant public crowdsaleInitialSupply = 48000000 * 10 ** 18; //48% of token
    
    uint256 constant public crowdsaleSoftCap = 2000 ether; //SoftCap
    uint256 constant public crowdsaleHardCap = 6000 ether; //HardCap
    
    uint256 constant public preICOStartTime = 1534755600; //Mon, 20 Aug 2018 09:00:00 GMT+0
    uint256 constant public mainICOStartTime = 1537434000; //Thu, 20 Sep 2018 09:00:00 GMT+0
    uint256 constant public mainICOFirstWeekEndTime = 1538643600; //Thu, 04 Oct 2018 09:00:00 GMT+0
    uint256 constant public mainICOSecondWeekEndTime = 1539853200; //Thu, 18 Oct 2018 09:00:00 GMT+0
    uint256 constant public mainICOThirdWeekEndTime = 1541062800; //Thu, 01 Nov 2018 09:00:00 GMT+0
    uint256 constant public mainICOFourthWeekEndTime = 1542272400; //Thu, 15 Nov 2018 09:00:00 GMT+0
    uint256 constant public mainICOEndTime = 1543482000; //Thu, 29 Nov 2018 09:00:00 GMT+0
    
    uint256 constant public tokenBaseRate = 549; // 1ETH = 549 CaHaTo
    
    // bonuses in percentage
    uint256 constant public preICOBonus = 93; //the discount of 93%, the price of 549 tokens is $54,9, instead of $686
    uint256 constant public firstWeekBonus = 68; //the discount of 68%, the price of 549 tokens is $219,6, instead of $686
    uint256 constant public secondWeekBonus = 52; //the discount of 52%, the price of 549 tokens is $329,4, instead of $686
    uint256 constant public thirdWeekBonus = 36; //the discount of 36%, the price of 549 tokens is $439,2, instead of $686
    uint256 constant public fourthWeekBonus = 0; //the discount of 0%, the price of 549 tokens is $686
    
    uint256 public teamSupply = 4000000 * 10 ** 18; //4% of tokens for developers
    uint256 public reserveSupply = 52000000 * 10 ** 18; //52% of tokens for work of system
    uint256 public weiRaised;
    uint256 public goal;
    uint256 public totalSupply = 100000000;
    
    // amount of tokens each address will receive at the end of the crowdsale
    mapping (address => uint256) public creditOf;

    // amount of ether invested by each address
    mapping (address => uint256) public weiInvestedBy;

    CarHashWhitelist public whitelist;
    
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
 
    /** Constructor CarHashToken*/
    constructor(CarHashToken _token, CarHashWhitelist _whitelist, address _wallet)
    {
        whitelist = _whitelist;
    }

    function _tokenPurchased(address buyer, address beneficiary, uint256 weiAmount) internal returns (bool) {
        // checks if the ether amount invested by the buyer is lower than his contribution cap
        require(SafeMath.add(weiInvestedBy[buyer], weiAmount) <= whitelist.contributionCap(buyer));

        // compute the amount of tokens given the baseRate
        uint256 tokens = SafeMath.mul(weiAmount, tokenBaseRate);

        emit TokenPurchase(buyer, beneficiary, weiAmount, tokens);

        return true;
    }

    // private sale funds will be held in this wallet
    // this address' balance will count for the crowdsale soft cap goal
    address constant public privateSaleWallet = 0x45dBE52da0fA6734aA43894EA15FD7a58f4C5E1A;

    // returns the token sale bonus percentage depending on the current time
    function getCurrentBonus() public view returns (uint256) {
        if (now < mainICOStartTime) {
            return preICOBonus;
        } else if (now < mainICOFirstWeekEndTime) {
            return firstWeekBonus;
        } else if (now < mainICOSecondWeekEndTime) {
            return secondWeekBonus;
        } else if (now < mainICOThirdWeekEndTime) {
            return thirdWeekBonus;
        } else if (now < mainICOFourthWeekEndTime) {
            return fourthWeekBonus;
        } else {
            return 0;
        }
    }

   
}