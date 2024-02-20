//SPDX-license-identifier: MIT
pragma solidity ^0.8.19;

import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "../../script/Interactions.s.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract InteractionsTest is Test {
    CreateSubscription public createSubscription;
    FundSubscription public fundSubscription;
    AddConsumer public addConsumer;
    Raffle public raffle;
    DeployRaffle public deployRaffle;

    function setUp() public {
        createSubscription = new CreateSubscription();
        fundSubscription = new FundSubscription();
        addConsumer = new AddConsumer();
        deployRaffle = new DeployRaffle();
        (raffle, ) = deployRaffle.run();
    }

    function testCreateSubscription() public {
        uint64 subscriptionId = createSubscription
            .createSubscriptionUsingConfig();
        assert(subscriptionId != 0);
    }

    function testFundSubscription() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            ,
            ,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeConfig();
        uint64 subscriptionId = createSubscription.createSubscription(
            vrfCoordinator,
            deployerKey
        );
        fundSubscription.fundSubscription(
            vrfCoordinator,
            subscriptionId,
            link,
            deployerKey
        );
        (uint96 balance, , , ) = VRFCoordinatorV2Mock(vrfCoordinator)
            .getSubscription(subscriptionId);
        assert(balance == fundSubscription.FUND_AMOUNT());
    }

    function testAddConsumer() public {
        deployRaffle = new DeployRaffle();
        (raffle, ) = deployRaffle.run();
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            ,
            ,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeConfig();
        uint64 subscriptionId = createSubscription.createSubscription(
            vrfCoordinator,
            deployerKey
        );
        fundSubscription.fundSubscription(
            vrfCoordinator,
            subscriptionId,
            link,
            deployerKey
        );
        addConsumer.addConsumer(
            address(raffle),
            vrfCoordinator,
            subscriptionId,
            deployerKey
        );
        (, , , address[] memory consumers) = VRFCoordinatorV2Mock(
            vrfCoordinator
        ).getSubscription(subscriptionId);
        assert(consumers[0] == address(raffle));
    }
}
