// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { console } from "forge-std/Script.sol";
import { BaseScript } from "./Base.s.sol";
import { IEAS, Attestation, AttestationRequest, AttestationRequestData } from "eas-contracts/IEAS.sol";
import { ISchemaRegistry } from "eas-contracts/ISchemaRegistry.sol";
import { ISchemaResolver } from "eas-contracts/resolver/ISchemaResolver.sol";

contract DeploySchema is BaseScript {
    IEAS eas;
    ISchemaRegistry schemaRegistry;

    function configureChain() public {
        if (block.chainid == 10) {
            // Optimism
            eas = IEAS(0x4200000000000000000000000000000000000021);
            schemaRegistry = ISchemaRegistry(0x4200000000000000000000000000000000000020);
        } else if (block.chainid == 8453) {
            // Base
            eas = IEAS(0x4200000000000000000000000000000000000021);
            schemaRegistry = ISchemaRegistry(0x4200000000000000000000000000000000000020);
        } else if (block.chainid == 42_161) {
            // Arbitrum
            eas = IEAS(0xbD75f629A22Dc1ceD33dDA0b68c546A1c035c458);
            schemaRegistry = ISchemaRegistry(0xA310da9c5B885E7fb3fbA9D66E9Ba6Df512b78eB);
        } else if (block.chainid == 42_220) {
            // Celo
            eas = IEAS(0x72E1d8ccf5299fb36fEfD8CC4394B8ef7e98Af92);
            schemaRegistry = ISchemaRegistry(0x5ece93bE4BDCF293Ed61FA78698B594F2135AF34);
        } else if (block.chainid == 84_532) {
            // Base Sepolia
            eas = IEAS(0x4200000000000000000000000000000000000021);
            schemaRegistry = ISchemaRegistry(0x4200000000000000000000000000000000000020);
        } else if (block.chainid == 11_155_111) {
            // Sepolia
            eas = IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e);
            schemaRegistry = ISchemaRegistry(0x0a7E2Ff54e76B8E6659aedc9103FB21c038050D0);
        } else {
            revert("Chain not supported");
        }
    }

    string schema =
        "uint256 chain_id,address contract_address,uint256 token_id,string title,string description,string[] sources";
    bytes32 nameSchema = 0x44d562ac1d7cd77e232978687fea027ace48f719cf1d58c7888e509663bb87fc;
    string name = "Hypercerts Creator Feed Attestation";
    bytes32 descriptionSchema = 0x21cbc60aac46ba22125ff85dd01882ebe6e87eb4fc46628589931ccbef9b8c94;
    string description = "Attestation for a creator feed on Hypercerts";

    function run() public broadcast {
        configureChain();

        console.log("Deploying Schema contract...");
        bytes32 deployedSchemaUID = schemaRegistry.register(schema, ISchemaResolver(address(0)), false);
        console.log("Schema deployed at");
        console.logBytes32(deployedSchemaUID);

        console.log("Naming schema...");
        bytes memory nameData = abi.encode(deployedSchemaUID, name);
        AttestationRequestData memory nameRequest = AttestationRequestData({
            recipient: address(0),
            expirationTime: 0,
            revocable: true,
            refUID: 0x0,
            data: nameData,
            value: 0
        });
        AttestationRequest memory nameAttestationRequest = AttestationRequest({ schema: nameSchema, data: nameRequest });
        bytes32 nameAttestationUID = eas.attest(nameAttestationRequest);
        console.log("Name attestation deployed at");
        console.logBytes32(nameAttestationUID);

        console.log("Describing schema...");
        bytes memory descriptionData = abi.encode(deployedSchemaUID, description);
        AttestationRequestData memory descriptionRequest = AttestationRequestData({
            recipient: address(0),
            expirationTime: 0,
            revocable: true,
            refUID: 0x0,
            data: descriptionData,
            value: 0
        });
        AttestationRequest memory descriptionAttestationRequest =
            AttestationRequest({ schema: descriptionSchema, data: descriptionRequest });
        bytes32 descriptionAttestationUID = eas.attest(descriptionAttestationRequest);
        console.log("Description attestation deployed at");
        console.logBytes32(descriptionAttestationUID);
    }
}
