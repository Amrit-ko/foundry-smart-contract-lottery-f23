//SPDX-license-identifier: MIT
pragma solidity ^0.8.19;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";

contract DeployRaffleTest is Test {
    Raffle public raffle;

    function testDeployRaffle() public {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, ) = deployRaffle.run();
        assert(address(raffle) != address(0));
    }
}
