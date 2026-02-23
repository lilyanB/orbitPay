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

## Anvil

Public Key
(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000.000000000000000000 ETH)
(1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000.000000000000000000 ETH)
(2) 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC (10000.000000000000000000 ETH)
Private Key
(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
(1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
(2) 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

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
