# Info

```
forge script script/Mocks.s.sol:MocksScript --rpc-url https://ethereum-sepolia-rpc.publicnode.com --broadcast --private-key abc123...
```

```
usdc_: contract IERC20 0x6e13B503bE2d289dfE762ef29A3b19377946236b
usdt_: contract IERC20 0xd2ECba4dFaE14CcE2d2e767974C01532C1f7EA07
weth_: contract IERC20 0x40e43BE2fEaf21cB459C4f493c14F0ad4A0E3451
```

```
forge script script/OrbitPayFactory.s.sol:OrbitPayFactoryScript --rpc-url https://ethereum-sepolia-rpc.publicnode.com --broadcast --private-key abc123...
```

```
orbitPayFactory_: contract OrbitPayFactory 0x5000d039abcf49238Bab7ecd60D276a2Cda7C2D0

createOrbitPay:
0xda282a14995bb28a423494b9d95a6ceea49edc3a
```

https://docs.chain.link/cre/guides/workflow/using-evm-client/forwarder-directory-ts

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
