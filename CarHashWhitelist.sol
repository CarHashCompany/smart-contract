pragma solidity ^0.4.24;

import './SafeMath.sol';
import './Ownable.sol';

/**
    This contract will handle the KYC contribution caps and the AML whitelist.
    The crowdsale contract checks this whitelist everytime someone tries to buy tokens.
*/
contract CarHashWhitelist is Ownable {
    using SafeMath for uint256;

    uint256 public usdPerEth;
    
    constructor(uint256 _usdPerEth) public {
        usdPerEth = _usdPerEth;
    }

    mapping(address => bool) public AMLWhitelisted;
    mapping(address => uint256) public contributionCap;

    /**
     * @dev sets the KYC contribution cap for one address
     * @param addr address
     * @return true if the operation was successful
     */
    function setKYCLevel(address addr, uint8 level) onlyOwner public returns (bool) {
        if (level >= 3) {
            contributionCap[addr] = 6000 ether; // crowdsale hard cap
        } else if (level == 2) {
            contributionCap[addr] = SafeMath.div(500000 * 10 ** 18, usdPerEth); // KYC Tier 2 - 500k USD
        } else if (level == 1) {
            contributionCap[addr] = SafeMath.div(3000 * 10 ** 18, usdPerEth); // KYC Tier 1 - 3k USD
        } else {
            contributionCap[addr] = 0;
        }

        return true;
    }

    function setKYCLevelsBulk(address[] addrs, uint8[] levels) onlyOwner external returns (bool success) {
        require(addrs.length == levels.length);

        for (uint256 i = 0; i < addrs.length; i++) {
            assert(setKYCLevel(addrs[i], levels[i]));
        }

        return true;
    }

    /**
     * @dev adds the specified address to the AML whitelist
     * @param addr address
     * @return true if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function setAMLWhitelisted(address addr, bool whitelisted) onlyOwner public returns (bool) {
        AMLWhitelisted[addr] = whitelisted;

        return true;
    }

    function setAMLWhitelistedBulk(address[] addrs, bool[] whitelisted) onlyOwner external returns (bool) {
        require(addrs.length == whitelisted.length);

        for (uint256 i = 0; i < addrs.length; i++) {
            assert(setAMLWhitelisted(addrs[i], whitelisted[i]));
        }

        return true;
    }
}