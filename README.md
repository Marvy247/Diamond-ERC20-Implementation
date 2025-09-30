# Diamond ERC20 Implementation

This project implements an ERC20 token using the Diamond pattern (EIP-2535), allowing for modular and upgradeable smart contracts on Ethereum.

## Overview

The Diamond pattern enables the creation of contracts with multiple facets, each containing different functionalities. This implementation provides an ERC20 token with a public mint function, split across several facets for better organization and upgradeability.

## Contracts

### Core Diamond Contracts
- **Diamond.sol**: The main diamond proxy contract that delegates calls to appropriate facets.
- **LibDiamond.sol**: Library containing diamond storage and utility functions.
- **IDiamondCut.sol**: Interface for diamond cut operations (adding/removing/replacing facets).
- **IDiamondLoupe.sol**: Interface for diamond loupe operations (facet introspection).
- **IERC173.sol**: Ownership interface.

### Facets
- **DiamondCutFacet.sol**: Implements facet management (add/replace/remove facets).
- **DiamondLoupeFacet.sol**: Implements facet introspection functions.
- **OwnershipFacet.sol**: Implements ownership transfer functionality.
- **ERC20Facet.sol**: Implements ERC20 standard functions plus a public mint function.

## Features

- **ERC20 Compliance**: Full ERC20 standard implementation (transfer, approve, transferFrom, etc.)
- **Public Mint**: Anyone can mint tokens to any address
- **Upgradeable**: Facets can be added, replaced, or removed without changing the diamond address
- **Modular**: Different functionalities are separated into distinct facets
- **Gas Efficient**: Uses delegatecall for facet execution

## Deployment

The contracts have been deployed to Sepolia testnet:

- DiamondCutFacet: `0x2f1F68931265cDA573679991AFA405B5Fb799115`
- DiamondLoupeFacet: `0x506D78Ce1140abf6130c50681FeDB6CDe49DF5d5`
- OwnershipFacet: `0x019185dE997101dd47386dD6Acd7DC3986765E9A`
- ERC20Facet: `0xDb57e85942744C2fa6bFd4605c45E32aF03BA44f`
- Diamond (Main Contract): `0xba7c67a315b17583B65fAA3FB2aEBa3341534574`

## Token Details

- Name: DiamondToken
- Symbol: DTK
- Decimals: 18

## Testing

Run the test suite with:
```bash
forge test
```

## Deployment Script

To deploy to a network:
```bash
forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast --verify --etherscan-api-key <API_KEY>
```

## Usage

Interact with the diamond contract at `0x935ec8A0C565b6a281D54920430C67fF9c4088F6` using any ERC20-compatible interface or directly call the facet functions.

## Architecture

The diamond contract uses a fallback function to route calls to the appropriate facet based on the function selector. Each facet implements a specific set of functions, allowing for clean separation of concerns and easier upgrades.

## Security

- Uses OpenZeppelin-inspired ERC20 implementation
- Follows EIP-2535 diamond standard
- Includes ownership controls for facet management
- All contracts are thoroughly tested

## License

MIT
