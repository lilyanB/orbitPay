# OrbitPay

**OrbitPay automates recurring crypto payments using decentralized workflows secured by Chainlink CRE.**

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

## Quick Links

- OrbitPay deployed by a company: https://sepolia.etherscan.io/address/0xe48F544178a7e9027773912Bd2960aD631Efe74d
- cre workflow: https://sepolia.etherscan.io/tx/0x2dc063ab40d463b129aeb0245584214685b9ab749f5352a1cf24b8e5539a0600
- tokens transferred thanks to CRE workflow: https://sepolia.etherscan.io/token/0x23a0485b021ca24efde51114823fdba761359780

## Overview

OrbitPay is a decentralized recurring payment infrastructure that enables businesses to automate subscriptions, salaries, DCA strategies, and other periodic transfers in crypto assets.

It combines:

- An enterprise API
- A Chainlink CRE workflow
- A secure onchain payment smart contract

# Non-Technical Description

## The Problem

Recurring payments today rely on centralized banking systems or payment processors.

These systems:

- Depend on trusted intermediaries
- Can be censored or restricted
- Lack blockchain transparency
- Require manual operational management
- Introduce single points of failure

In Web3, recurring payments are not standardized — especially when users want to pay in different crypto assets.

## The Solution

OrbitPay enables businesses to automate recurring crypto payments in **USDC, WETH, or WBTC**.

## Supported Tokens

- **USDC**
- **WETH**
- **WBTC**

## Use Cases

- Salaries paid in crypto
- Web3 SaaS subscriptions
- DAO recurring contributions
- B2B recurring invoices
- Tokenized rent payments

# Technical Description

## System Architecture

The system consists of:

1. Enterprise API
2. CRE Workflow
3. Payment Smart Contract

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
