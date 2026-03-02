# OrbitPay

**OrbitPay automates recurring crypto payments using decentralized workflows secured by Chainlink CRE.**

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
