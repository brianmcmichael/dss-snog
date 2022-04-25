// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.12;

// Includes Median and OSM functions
interface OracleLike {
    function kiss(address) external;
}

contract DssSnog {

    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    modifier auth {
        require(wards[msg.sender] == 1, "DssSnog/not-authorized");
        _;
    }

    mapping (address => uint256) public snoggers;
    function snogon(address usr)  external auth { snoggers[usr] = 1; emit SnogOn(usr);}
    function snogoff(address usr) external can { snoggers[usr] = 0; emit SnogOff(usr);
    }
    modifier can {
        require(wards[msg.sender] == 1 || snoggers[msg.sender] == 1, "DssSnog/not-authorized");
        _;
    }

    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event SnogOn(address indexed usr);
    event SnogOff(address indexed usr);
    event Kiss(address indexed oracle, address reader);

    constructor() {
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    function kiss(address _oracle, address _reader) external can {
        OracleLike(_oracle).kiss(_reader);
        emit Kiss(_oracle, _reader);
    }
}
