// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Guardable} from "../../../contracts/Guardable.sol";
import {GuardableMock} from "../../mocks/GuardableMock.sol";

contract GuardableTest is Test {
    GuardableMock public guardable;
    address public guardian = makeAddr("guardian");
    address public bob = makeAddr("bob");
    address public rob = makeAddr("rob");
    address public alice = makeAddr("alice");

    function setUp() public {
        guardable = new GuardableMock(guardian);
        address[] memory newGuardians = new address[](2);
        bool[] memory enableds = new bool[](2);
        newGuardians[0] = alice;
        newGuardians[1] = rob;
        enableds[0] = true;
        enableds[1] = true;
        guardable.setGuardians(newGuardians, enableds);
    }

    function testSetGuardians() public {
        assertTrue(guardable.isGuardian(guardian));
        assertFalse(guardable.isGuardian(bob));
        address[] memory newGuardians = new address[](2);
        bool[] memory enableds = new bool[](1);
        newGuardians[0] = guardian;
        newGuardians[1] = bob;
        enableds[0] = false;
        vm.expectRevert(Guardable.Guardable__InconsistentParamsLength.selector);
        guardable.setGuardians(newGuardians, enableds);
        enableds = new bool[](2);
        enableds[0] = false;
        enableds[1] = true;
        guardable.setGuardians(newGuardians, enableds);
        assertFalse(guardable.isGuardian(guardian));
        assertTrue(guardable.isGuardian(bob));
    }

    function testOnlyGuardian() public {
        vm.expectRevert(Guardable.Guardable__NotGuardian.selector);
        guardable.shouldRevertIfNotGuardian();
        vm.prank(guardian);
        guardable.shouldRevertIfNotGuardian();
    }

    function testOnlyNotCursed() public {
        vm.prank(guardian);
        guardable.shouldRevertIfCursedGuardian();
        vm.prank(rob);
        guardable.curse(guardian);
        vm.prank(alice);
        guardable.curse(guardian);
        vm.prank(guardian);
        vm.expectRevert(Guardable.Guardable__CursedGuardian.selector);
        guardable.shouldRevertIfCursedGuardian();
    }

    function testCurseAndRevokeCurse() public {
        vm.prank(bob);
        vm.expectRevert(Guardable.Guardable__NotGuardian.selector);
        guardable.curse(guardian);        
        vm.prank(rob);
        guardable.curse(guardian);
        assertFalse(guardable.isGuardianCursed(guardian));
        vm.prank(alice);
        guardable.curse(guardian);
        assertTrue(guardable.isGuardianCursed(guardian));
        vm.prank(guardian);
        vm.expectRevert(Guardable.Guardable__CursedGuardian.selector);
        guardable.curse(alice);
        vm.prank(bob);
        vm.expectRevert(Guardable.Guardable__NotGuardian.selector);
        guardable.revokeCurse(guardian);
        vm.prank(alice);
        vm.expectRevert(Guardable.Guardable__NotCursed.selector);
        guardable.revokeCurse(bob);
        vm.prank(alice);
        guardable.revokeCurse(guardian);
        assertFalse(guardable.isGuardianCursed(guardian));
    }

    function testBreakCurse() public {
        vm.prank(guardian);
        vm.expectRevert(Guardable.Guardable__NotCursed.selector);
        guardable.breakCurse(alice);
        vm.prank(rob);
        guardable.curse(guardian);
        vm.prank(alice);
        guardable.curse(guardian);
        assertTrue(guardable.isGuardianCursed(guardian));
        vm.prank(guardian);
        vm.expectRevert(Guardable.Guardable__CannotBreakCurse.selector);
        guardable.breakCurse(alice);
        address[] memory newGuardians = new address[](1);
        bool[] memory enableds = new bool[](1);
        newGuardians[0] = alice;
        enableds[0] = false;
        guardable.setGuardians(newGuardians, enableds);
        vm.prank(guardian);
        guardable.breakCurse(alice);
    }
}
