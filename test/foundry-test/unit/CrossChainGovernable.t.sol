// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {CrossChainGovernable} from "../../../contracts/CrossChainGovernable.sol";
import {CrossChainGovernableMock} from "../../mocks/CrossChainGovernableMock.sol";

contract CrossChainGovernableTest is Test {
    CrossChainGovernableMock public ccGovernable;
    address public governor = makeAddr("governor");
    uint64 public governorChainSelector = 1337;
    uint64 public anotherChainSelector = 7331;
    address public bob = makeAddr("bob");
    address public alice = makeAddr("alice");

    uint64 private constant TRANSFER_GOVERNANCE_DELAY = 3 days;

    function setUp() public {
        vm.prank(governor);
        ccGovernable = new CrossChainGovernableMock(governor, governorChainSelector);
    }

    function testSetPendingGovernor() public {
        assertEq(ccGovernable.getPendingGovernor(), address(0));
        assertEq(ccGovernable.getGovTransferReqTimestamp(), uint64(0));
        vm.expectRevert(CrossChainGovernable.CrossChainGovernable__ZeroAddress.selector);
        ccGovernable.setPendingGovernor(address(0), 0);
        vm.expectRevert(CrossChainGovernable.CrossChainGovernable__ZeroChainSelector.selector);
        ccGovernable.setPendingGovernor(bob, 0);
        ccGovernable.setPendingGovernor(bob, anotherChainSelector);
        assertEq(ccGovernable.getPendingGovernor(), bob);
        assertEq(ccGovernable.getPendingGovernorChainSelector(), anotherChainSelector);
        assertEq(ccGovernable.getGovTransferReqTimestamp(), block.timestamp);
    }

    function testGovernorTransferGovernance() public {
        vm.expectRevert(CrossChainGovernable.CrossChainGovernable__ZeroAddress.selector);
        ccGovernable.transferGovernance();
        ccGovernable.setPendingGovernor(bob, anotherChainSelector);
        vm.expectRevert(CrossChainGovernable.CrossChainGovernable__TooEarly.selector);
        ccGovernable.transferGovernance();
        vm.warp(block.timestamp + TRANSFER_GOVERNANCE_DELAY + 1);
        vm.prank(bob);
        ccGovernable.transferGovernance();
        assertEq(ccGovernable.getGovernor(), bob);
    }

    function testPendingGovernorTransferGovernance() public {
        ccGovernable.setPendingGovernor(bob, anotherChainSelector);
        vm.expectRevert(CrossChainGovernable.CrossChainGovernable__TooEarly.selector);
        ccGovernable.transferGovernance();
        vm.warp(block.timestamp + TRANSFER_GOVERNANCE_DELAY + 1);
        ccGovernable.transferGovernance();
        assertEq(ccGovernable.getGovernor(), bob);
    }

    function testShouldRevertIfNotCrossChainGovernor() public {
        vm.expectRevert(CrossChainGovernable.CrossChainGovernable__NotAuthorized.selector);
        ccGovernable.shouldRevertIfNotCrossChainGovernor(bob, anotherChainSelector);
        vm.expectRevert(CrossChainGovernable.CrossChainGovernable__NotAuthorized.selector);
        ccGovernable.shouldRevertIfNotCrossChainGovernor(address(0), 0);
    }
}
