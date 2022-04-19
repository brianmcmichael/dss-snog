// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./DssSnog.sol";

contract DssSnogTest is DSTest {
    DssSnog snog;

    function setUp() public {
        snog = new DssSnog();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
