// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {AaveV3Polygon_ADIAndBridgeAdaptersUpdate_20240305} from './AaveV3Polygon_ADIAndBridgeAdaptersUpdate_20240305.sol';
import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import './BaseTest.sol';
import {AaveV3Ethereum_ADIAndBridgeAdaptersUpdate_20240305} from './AaveV3Ethereum_ADIAndBridgeAdaptersUpdate_20240305.sol';

/**
 * @dev Test for AaveV3Polygon_ADIAndBridgeAdaptersUpdate_20240305
 * command: make test-contract filter=AaveV3Polygon_ADIAndBridgeAdaptersUpdate_20240305
 */
contract AaveV3Polygon_ADIAndBridgeAdaptersUpdate_20240305_Test is BaseTest {
  AaveV3Polygon_ADIAndBridgeAdaptersUpdate_20240305 internal proposal;
  AaveV3Ethereum_ADIAndBridgeAdaptersUpdate_20240305 internal ethereumPayload;

  function setUp() public {
    ccc = GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER;
    proxyAdmin = MiscPolygon.PROXY_ADMIN;

    vm.createSelectFork(vm.rpcUrl('polygon'), 54566890);
    proposal = new AaveV3Polygon_ADIAndBridgeAdaptersUpdate_20240305();
    ethereumPayload = new AaveV3Ethereum_ADIAndBridgeAdaptersUpdate_20240305();
  }

  /**
   * @dev executes the generic test suite including e2e and config snapshots
   */
  function test_defaultProposalExecution() public {
    _testTrustedRemotes();
    _testCorrectPathConfiguration();
    _testCorrectAdapterNames();

    _testCurrentReceiversAreAllowed();
    _testAllReceiversAreRepresented();
    _testCurrentForwarders();
    _testImplementationAddress(proposal.NEW_CROSS_CHAIN_CONTROLLER_IMPLEMENTATION(), false);

    executePayload(vm, address(proposal));

    _testAfterReceiversAreAllowed();
    _testAllReceiversAreRepresentedAfter();
    _testAfterForwarders();
    _testImplementationAddress(proposal.NEW_CROSS_CHAIN_CONTROLLER_IMPLEMENTATION(), true);
  }

  function _testCorrectAdapterNames() internal {
    _testAdapterName(proposal.CCIP_NEW_ADAPTER(), 'CCIP adapter');
    _testAdapterName(proposal.LZ_NEW_ADAPTER(), 'LayerZero adapter');
    _testAdapterName(proposal.HL_NEW_ADAPTER(), 'Hyperlane adapter');
    _testAdapterName(proposal.POL_NEW_ADAPTER(), 'Polygon native adapter');
  }

  function _testCorrectPathConfiguration() internal {
    assertEq(ethereumPayload.CCIP_NEW_ADAPTER(), proposal.DESTINATION_CCIP_NEW_ADAPTER());
    assertEq(ethereumPayload.LZ_NEW_ADAPTER(), proposal.DESTINATION_LZ_NEW_ADAPTER());
    assertEq(ethereumPayload.HL_NEW_ADAPTER(), proposal.DESTINATION_HL_NEW_ADAPTER());
    assertEq(ethereumPayload.POL_NEW_ADAPTER(), proposal.DESTINATION_POL_NEW_ADAPTER());
  }

  function _testTrustedRemotes() internal {
    _testTrustedRemoteByChain(
      proposal.CCIP_NEW_ADAPTER(),
      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
      ChainIds.MAINNET
    );
    _testTrustedRemoteByChain(
      proposal.LZ_NEW_ADAPTER(),
      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
      ChainIds.MAINNET
    );
    _testTrustedRemoteByChain(
      proposal.HL_NEW_ADAPTER(),
      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
      ChainIds.MAINNET
    );
    _testTrustedRemoteByChain(
      proposal.POL_NEW_ADAPTER(),
      GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
      ChainIds.MAINNET
    );
  }

  function _testCurrentForwarders() internal {
    ICrossChainForwarder.ChainIdBridgeConfig[]
      memory adapters = new ICrossChainForwarder.ChainIdBridgeConfig[](4);
    adapters[0].currentChainBridgeAdapter = proposal.CCIP_ADAPTER_TO_REMOVE();
    adapters[1].currentChainBridgeAdapter = proposal.LZ_ADAPTER_TO_REMOVE();
    adapters[2].currentChainBridgeAdapter = proposal.HL_ADAPTER_TO_REMOVE();
    adapters[3].currentChainBridgeAdapter = proposal.POL_ADAPTER_TO_REMOVE();

    _checkForwarderAdapterCorrectness(ChainIds.MAINNET, adapters, false);
  }

  function _testAfterForwarders() internal {
    ICrossChainForwarder.ChainIdBridgeConfig[]
      memory adapters = new ICrossChainForwarder.ChainIdBridgeConfig[](4);
    adapters[0].currentChainBridgeAdapter = proposal.CCIP_NEW_ADAPTER();
    adapters[1].currentChainBridgeAdapter = proposal.LZ_NEW_ADAPTER();
    adapters[2].currentChainBridgeAdapter = proposal.HL_NEW_ADAPTER();
    adapters[3].currentChainBridgeAdapter = proposal.POL_NEW_ADAPTER();
    adapters[0].destinationBridgeAdapter = proposal.DESTINATION_CCIP_NEW_ADAPTER();
    adapters[1].destinationBridgeAdapter = proposal.DESTINATION_LZ_NEW_ADAPTER();
    adapters[2].destinationBridgeAdapter = proposal.DESTINATION_HL_NEW_ADAPTER();
    adapters[3].destinationBridgeAdapter = proposal.DESTINATION_POL_NEW_ADAPTER();

    _checkForwarderAdapterCorrectness(ChainIds.MAINNET, adapters, true);
  }

  function _testAllReceiversAreRepresented() internal {
    address[] memory adapters = new address[](4);
    adapters[0] = proposal.CCIP_ADAPTER_TO_REMOVE();
    adapters[1] = proposal.LZ_ADAPTER_TO_REMOVE();
    adapters[2] = proposal.HL_ADAPTER_TO_REMOVE();
    adapters[3] = proposal.POL_ADAPTER_TO_REMOVE();

    _testReceiverAdaptersByChain(ChainIds.MAINNET, adapters);
  }

  function _testAllReceiversAreRepresentedAfter() internal {
    address[] memory adapters = new address[](4);
    adapters[0] = proposal.CCIP_NEW_ADAPTER();
    adapters[1] = proposal.LZ_NEW_ADAPTER();
    adapters[2] = proposal.HL_NEW_ADAPTER();
    adapters[3] = proposal.POL_NEW_ADAPTER();

    _testReceiverAdaptersByChain(ChainIds.MAINNET, adapters);
  }

  function _testCurrentReceiversAreAllowed() internal {
    // check that current bridges are allowed
    _testReceiverAdapterAllowed(proposal.CCIP_ADAPTER_TO_REMOVE(), ChainIds.MAINNET, true);
    _testReceiverAdapterAllowed(proposal.LZ_ADAPTER_TO_REMOVE(), ChainIds.MAINNET, true);
    _testReceiverAdapterAllowed(proposal.HL_ADAPTER_TO_REMOVE(), ChainIds.MAINNET, true);
    _testReceiverAdapterAllowed(proposal.POL_ADAPTER_TO_REMOVE(), ChainIds.MAINNET, true);
  }

  function _testAfterReceiversAreAllowed() internal {
    // check that old bridges are no longer allowed
    _testReceiverAdapterAllowed(proposal.CCIP_ADAPTER_TO_REMOVE(), ChainIds.MAINNET, false);
    _testReceiverAdapterAllowed(proposal.LZ_ADAPTER_TO_REMOVE(), ChainIds.MAINNET, false);
    _testReceiverAdapterAllowed(proposal.HL_ADAPTER_TO_REMOVE(), ChainIds.MAINNET, false);
    _testReceiverAdapterAllowed(proposal.POL_ADAPTER_TO_REMOVE(), ChainIds.MAINNET, false);

    // check that new bridges are allowed
    _testReceiverAdapterAllowed(proposal.CCIP_NEW_ADAPTER(), ChainIds.MAINNET, true);
    _testReceiverAdapterAllowed(proposal.LZ_NEW_ADAPTER(), ChainIds.MAINNET, true);
    _testReceiverAdapterAllowed(proposal.HL_NEW_ADAPTER(), ChainIds.MAINNET, true);
    _testReceiverAdapterAllowed(proposal.POL_NEW_ADAPTER(), ChainIds.MAINNET, true);
  }
}
