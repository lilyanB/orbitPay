# Info

## Network Configuration

| Network                      | RPC URL                                                                           |
| ---------------------------- | --------------------------------------------------------------------------------- |
| **Tenderly Virtual Sepolia** | `https://virtual.sepolia.eu.rpc.tenderly.co/8e5c0089-57b6-4643-9ef0-7353f9ed6aa6` |
| **Sepolia**                  | `https://ethereum-sepolia-rpc.publicnode.com`                                     |

## Deployed Contracts

### Mock Tokens

| Contract | Tenderly Virtual Sepolia                     | Sepolia                                      |
| -------- | -------------------------------------------- | -------------------------------------------- |
| **USDT** | `0xf52FF74E6e889BFa690b22F871385c5B3ABF1bFB` | `0xa0a5a661f7fad0E1F5B5a9C479de51eEEf4D1223` |
| **USDC** | `0xf75e01b4fbe2fF23361ee6D2F5714426441bcA09` | `0x23a0485b021CA24efde51114823FDbA761359780` |
| **WETH** | `0x36D88642Da6Ef14bAEd52379DE325D3980a2F686` | `0x260B90dFf3F586B1141790a212D7437D5521d5B8` |

### OrbitPay Contracts

| Contract            | Tenderly Virtual Sepolia                     | Sepolia                                      |
| ------------------- | -------------------------------------------- | -------------------------------------------- |
| **OrbitPayFactory** | `0x3BeB5588FAcB269761D45641016e9E2E89f94230` | `0xb13d776541cbb3694B4E10b9122Eb9F6A903130f` |

## Deployment Commands

### Deploy Mocks

**Tenderly:**

```bash
forge script script/Mocks.s.sol:MocksScript \
  --rpc-url https://virtual.sepolia.eu.rpc.tenderly.co/8e5c0089-57b6-4643-9ef0-7353f9ed6aa6 \
  --broadcast --private-key abc123...
```

**Sepolia:**

```bash
forge script script/Mocks.s.sol:MocksScript \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --broadcast --private-key abc123...
```

### Deploy OrbitPayFactory

**Tenderly:**

```bash
forge script script/OrbitPayFactory.s.sol:OrbitPayFactoryScript 0x607A577659Cad2A2799120DfdEEde39De2D38706 \
  --rpc-url https://virtual.sepolia.eu.rpc.tenderly.co/8e5c0089-57b6-4643-9ef0-7353f9ed6aa6 \
  --broadcast --private-key abc123...
```

**Sepolia:**

```bash
forge script script/OrbitPayFactory.s.sol:OrbitPayFactoryScript 0x607A577659Cad2A2799120DfdEEde39De2D38706 \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --broadcast --private-key abc123...
```

https://docs.chain.link/cre/guides/workflow/using-evm-client/forwarder-directory-ts

Check userInfo:

```
cast call 0xe48F544178a7e9027773912Bd2960aD631Efe74d "getUserInfo(address)" 0x607A577659Cad2A2799120DfdEEde39De2D38706 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
cast abi-decode "getUserInfo(address)((uint8,uint40))" 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069a453b0
```

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
