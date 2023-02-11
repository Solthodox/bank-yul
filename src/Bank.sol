//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract YulBank {
    uint256 private _totalDeposits; // slot 0
    uint256 private _maxWithdraw; // slot 1
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    bytes32[] private history;
    

    constructor(uint256 maxWithdraw){
        _maxWithdraw = maxWithdraw;
    }

    function deposit(uint256 value) external payable{
        uint256 slot;
        assembly{
            slot:=balances.slot
        }
        bytes32 location = keccak256(abi.encode(address(msg.sender), uint256(slot)));
        assembly{
            if lt(callvalue(), value){
                revert(0,0)
            }
            if eq(value,0){
                revert(0,0)
            }

            sstore(0, add(sload(0),callvalue()))
            sstore(location, add(sload(location), callvalue()))
        }
        pushToHistory(keccak256(abi.encodePacked(msg.sender, value, block.timestamp)));
    }

    function withdrawFrom(address from ,uint256 value) external{

    }

    function withdraw(uint256 value) external{
        uint256 slot;
        assembly{
            slot:=balances.slot
        }
        bytes32 location = keccak256(abi.encode(address(msg.sender), uint256(slot)));
        assembly{
            if gt(value, sload(1)){
                revert(0,0)
            }
            if eq(value,0){
                revert(0,0)
            }
            if gt(value, sload(location)){
                revert(0,0)
            }
            sstore(0, sub(sload(0),value))
            sstore(location, sub(sload(location), value))
        }

        pushToHistory(keccak256(abi.encodePacked(msg.sender, value, block.timestamp)));
        
    }

    function balanceOf(address account) public view returns(uint256 ret){
        uint256 slot;
        assembly{
            slot:=balances.slot
        }
        bytes32 location = keccak256(abi.encode(address(account), slot));
        assembly{
            ret := sload(location)
        }
    }

    function allowance(address owner , address spender) public view returns(uint256 ret){
        uint256 slot;
        assembly{
            slot:= allowances.slot
        }
        bytes32 location = keccak256(abi.encode(
            keccak256(abi.encode(spender, slot)),
            owner
        ));
        assembly{
            ret := sload(location)
        }

    }

    function getHistory(uint256 index) public view returns(uint256 ret){
        uint256 slot;
        assembly{
            slot := history.slot
        }

        bytes32 location = keccak256(abi.encode(slot));
        assembly{
            ret := sload(add(location, index))
        }
    }


    function approve(address spender, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Balance not enough");
        uint256 slot;
        assembly{
            slot:= allowances.slot
        }
        bytes32 location = keccak256(abi.encode(
            keccak256(abi.encode(spender, slot)),
            msg.sender
        ));
        assembly{    
            sstore(location, amount)
        }
    }

    function totalDeposits() public view returns(uint256 ret){
        assembly{
            ret := sload(0)
        }
    }

    function maxWithdraw() public view returns(uint256 ret){
        assembly{
            ret := sload(1)
        }
    }

    function pushToHistory(bytes32 data) internal {
        uint256 slot;
        assembly{
            slot := history.slot
        }
        bytes32 location = keccak256(abi.encode(slot));
        assembly{
            let len := sload(slot)
            sstore(add(location,len), data)
        }
    }


}