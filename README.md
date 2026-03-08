# OrbitPay

**Automated recurring crypto payments powered by Chainlink CRE workflows**

## 🎥 Demo Video

<video src="finalPres.mp4" controls></video>

## Quick Links

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

- OrbitPay deployed by a company: https://sepolia.etherscan.io/address/0xe48F544178a7e9027773912Bd2960aD631Efe74d
- cre workflow: https://sepolia.etherscan.io/tx/0x2dc063ab40d463b129aeb0245584214685b9ab749f5352a1cf24b8e5539a0600
- tokens transferred thanks to CRE workflow: https://sepolia.etherscan.io/token/0x23a0485b021ca24efde51114823fdba761359780

## 📋 Project Presentation

### What is OrbitPay?

OrbitPay is a decentralized recurring payment infrastructure that enables businesses to automate subscriptions, salaries, DCA strategies, and other periodic transfers in crypto assets (USDC, WETH, WBTC).

**The Problem:**
Recurring payments today rely on centralized banking systems or payment processors that depend on trusted intermediaries, can be censored, lack blockchain transparency, require manual operational management, and introduce single points of failure. In Web3, recurring payments are not standardized.

**The Solution:**
OrbitPay automates recurring crypto payments using three components:

1. **Enterprise API** - Returns who needs to be paid and how much via GET /api/mustPay endpoint
2. **Chainlink CRE Workflow** - Executes HTTP calls to the API through BFT consensus, validates results across multiple nodes, and triggers on-chain payments
3. **Smart Contracts** - Secure on-chain payment contracts (OrbitPayFactory and OrbitPay) that handle the actual token transfers

The system leverages Chainlink CRE's HTTP capability to fetch payment data in a decentralized manner, ensuring that no single point of failure can manipulate payment execution.

### How is it Built?

- **Smart Contracts**: Solidity contracts using Foundry framework (OrbitPayFactory, OrbitPay, ReceiverTemplate)
- **Chainlink CRE**: TypeScript workflows for decentralized automation and HTTP consensus
- **Frontend**: Next.js 13 App Router with wagmi for Web3 integration
- **Networks**: Deployed on Sepolia testnet and Tenderly Virtual Sepolia
- **Token Support**: ERC20 mock tokens (USDC, WETH, USDT) for testing

### Key Challenges

- **Batch Processing**: Implementing efficient batch processing (BATCH_SIZE = 20) to handle multiple payments in a single transaction while staying within gas limits
- **HTTP Consensus**: Ensuring the enterprise API responses are validated through BFT consensus using Chainlink CRE's `consensusIdenticalAggregation` to prevent manipulation
- **Report Signing & Verification**: Properly encoding payment data as ABI parameters and generating signed reports that the smart contract can verify on-chain
- **Multi-network Deployment**: Managing deployments across Sepolia and Tenderly Virtual Sepolia with different contract addresses
- **Gas Optimization**: Balancing between batch size and gas costs while maintaining reliability

### Chainlink Usage

**Primary Integration:** [CRE Workflow Implementation](cre/orbitPay/main.ts)

This demonstrates:

- **CronCapability**: Automated scheduled execution of payment workflows
- **HTTPClient with BFT Consensus**: Fetching payment data from enterprise API with `consensusIdenticalAggregation()` ensuring multiple nodes validate the response
- **EVMClient**: Writing cryptographically signed reports to the blockchain
- **Report Generation**: Creating verifiable on-chain reports using `runtime.report()` with ECDSA signatures and keccak256 hashing

The workflow ensures trustless, decentralized execution of recurring payments without relying on centralized automation services.

---

## Enterprise API

Endpoint:
GET /api/mustPay
Example response:

```json
[
  {
    "address": "0x...",
    "usdAmount": "100"
  }
]
```

This call is executed via CRE’s HTTP capability and validated through BFT consensus.
Multiple nodes independently fetch the prices and produce a verified aggregated result.

# V2

We want to add in our smart contract the ability to pay in any ERC20 token with an internal call to an oracle to get the price of the token in USD and calculate the amount to pay.
