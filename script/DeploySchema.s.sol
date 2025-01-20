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
        // TODO: add chain configuration
        if (block.chainid == 10) {
            // Optimism
            eas = IEAS(0x4200000000000000000000000000000000000021);
            schemaRegistry = ISchemaRegistry(0x4200000000000000000000000000000000000020);
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
