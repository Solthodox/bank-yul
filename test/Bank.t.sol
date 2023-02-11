// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract CounterTest is Test {
    YulBank public bank;

    function setUp() public {
        bank = new YulBank(1000 ether);
    }

    function testDeposit(uint256 a) public {
        vm.assume(a>0 && a<200 ether);
        bank.deposit{value: a}(a);
        assertEq(bank.balanceOf(address(this)), a);
        assertEq(bank.totalDeposits(), a);
        console.log(bank.getHistory(0));
    }

    function testWithdraw(uint256 a) public {
        vm.assume(a>2 && a<200 ether);
        bank.deposit{value: a}(a);
        console.log(bank.getHistory(0));

        uint256 balanceBefore = bank.balanceOf(address(this));
        if(a > bank.maxWithdraw()){
            vm.expectRevert(bytes(''));
            bank.withdraw(a);
        }else{
            bank.withdraw(a);
            assertLt(bank.balanceOf(address(this)), balanceBefore);
            assertEq(bank.balanceOf(address(this)),0);
            assertEq(bank.totalDeposits(),0);
            console.log(bank.getHistory(1));
        }
    }

    function testApprove() public {
        bank.deposit{value : 2 ether}(2 ether);
        address spender = address(0x4);
        bank.approve(spender , 1 ether);
        assertEq(bank.allowance(address(this), spender),1 ether);
    }

    function testWitdrawFrom() public {
        bank.deposit{value : 2 ether}(2 ether);
        address spender = address(0x4);
        bank.approve(spender , 1 ether);
        assertEq(bank.allowance(address(this), spender),1 ether);
        vm.prank(spender);
        bank.withdrawFrom(address(this), 1 ether);
    }

  
}
