// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.12;

import "ds-test/test.sol";

import "./DssSnog.sol";

interface Hevm {
    function warp(uint256) external;
    function store(address,bytes32,bytes32) external;
    function load(address,bytes32) external;
}

interface CL {
    function getAddress(bytes32 key) external view returns (address);
}

contract AuthUser {
    DssSnog immutable snogger;
    constructor(DssSnog _snogger) {
        snogger = _snogger;
    }
    function snogon(address u) external {
        snogger.snogon(u);
    }
    function snogoff(address u) external {
        snogger.snogoff(u);
    }
    function kiss(address o, address r) external {
        snogger.kiss(o, r);
    }
}

interface OracleTester {
    function rely(address) external;
    function deny(address) external;
    function wards(address) external view returns (uint256);
    function bud(address) external view returns (uint256);
    function peek() external view returns (bytes32, bool);
    function peep() external view returns (bytes32, bool);
    function read() external view returns (bytes32);
}

contract Reader {
    function peek(address _oracle) external view returns (uint256) {
        (bytes32 val, bool has) = OracleTester(_oracle).peek();
        require(has);
        return uint256(val);
    }
    function peep(address _oracle) external view returns (uint256) {
        (bytes32 val, bool has) = OracleTester(_oracle).peep();
        require(has);
        return uint256(val);
    }
    function read(address _oracle) external view returns (uint256) {
        return uint256(OracleTester(_oracle).read());
    }
    function bud(address _oracle) external view returns (uint256) {
        return OracleTester(_oracle).bud(address(this));
    }
}

contract DssSnogTest is DSTest {
    Hevm hevm;

    DssSnog  snogger;
    AuthUser grantor;
    Reader   reader;

    address osm;
    address unilposm;
    address crvlposm;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    // chainlog
    CL constant cl = CL(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    function setUp() public {
        hevm    = Hevm(address(CHEAT_CODE));
        snogger = new DssSnog();
        grantor = new AuthUser(snogger);
        reader  = new Reader();

        osm      = gaddr("PIP_ETH");
        unilposm = gaddr("PIP_UNIV2DAIETH");
        crvlposm = gaddr("PIP_CRVV1ETHSTETH");

        // Prospective user must be authed to add
        snogger.snogon(address(grantor));

        // Snogger must be relied on oracles for access
        // OSM
        hackWard(osm);
        OracleTester(osm).rely(address(snogger));
        // UniV2 OSM
        hackWard(unilposm);
        OracleTester(unilposm).rely(address(snogger));
        // CRV OSM
        hackWard(crvlposm);
        OracleTester(crvlposm).rely(address(snogger));
    }

    function testKissOne() public {

        assertEq(reader.bud(osm), 0);
        grantor.kiss(osm, address(reader));
        assertEq(reader.bud(osm), 1);
        assertTrue(reader.peek(osm) > 0);
        assertTrue(reader.peep(osm) > 0);
        assertTrue(reader.read(osm) > 0);

        assertEq(reader.bud(unilposm), 0);
        grantor.kiss(unilposm, address(reader));
        assertEq(reader.bud(unilposm), 1);
        assertTrue(reader.peek(unilposm) > 0);
        assertTrue(reader.peep(unilposm) > 0);
        assertTrue(reader.read(unilposm) > 0);

        // TODO: test against live crv oracle or fixture (when live)
        //assertEq(reader.bud(crvlposm), 0);
        //grantor.kiss(crvlposm, address(reader));
        //assertEq(reader.bud(crvlposm), 1);
        //assertTrue(reader.peek(crvlposm) > 0);
        //assertTrue(reader.peep(crvlposm) > 0);
        //assertTrue(reader.read(crvlposm) > 0);
    }

    function testFailUnauthed() public {
        // grantor can't kiss an arbitrary osm
        grantor.kiss(gaddr("PIP_BAT"), address(reader));
    }

    function testFailNotReader() public view {
        // ensure we can't read normally
        reader.peek(osm);
    }

    function testSnogOn() public {
        // Set in setup
        assertEq(snogger.snoggers(address(grantor)), 1);
        assertEq(snogger.snoggers(address(reader)), 0);

        snogger.snogon(address(reader));

        assertEq(snogger.snoggers(address(reader)), 1);
    }

    function testWardSnogOff() public {
        // Set in setup
        assertEq(snogger.snoggers(address(grantor)), 1);

        snogger.snogoff(address(grantor));  // ward

        assertEq(snogger.snoggers(address(grantor)), 0);
    }

    function testSelfSnogOff() public {
        // Set in setup
        assertEq(snogger.snoggers(address(grantor)), 1);

        grantor.snogoff(address(grantor));  // self

        assertEq(snogger.snoggers(address(grantor)), 0);
    }

    function testFailSnoggerCanNotCreateNewSnoggers() public {
        grantor.snogon(address(reader));
    }

    function gaddr(bytes32 key) internal view returns (address val) {
        return cl.getAddress(key);
    }

    function hackWard(address _auth) internal {
        // assume wards are in slot 0
        hevm.store(
            _auth,
            keccak256(abi.encode(address(this), uint256(0))), // Grant auth to test contract
            bytes32(uint256(1))
        );
    }
}
