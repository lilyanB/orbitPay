# OrbitPay

**OrbitPay automates recurring crypto payments using decentralized workflows secured by Chainlink CRE.**

---

## Overview

OrbitPay is a decentralized recurring payment infrastructure that enables businesses to automate subscriptions, salaries, DCA strategies, and other periodic transfers in crypto assets.

It combines:

- An enterprise API
- A Chainlink CRE workflow
- A secure onchain payment smart contract
- Decentralized price verification

The system eliminates manual operations and single points of failure while maintaining full onchain transparency and institutional-grade security.

---

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

---

## The Solution

OrbitPay enables businesses to automate recurring crypto payments in **USDC, WETH, or WBTC**, while keeping pricing consistent and fair.

### How it works (simple version)

1. Each user chooses the token they want to use (USDC, WETH, or WBTC).
2. The user grants approval once to the payment smart contract.
3. Every month, a decentralized workflow checks who needs to pay.
4. The workflow fetches the current market prices of USDC, WETH, and WBTC.
5. The correct token amount is calculated based on the subscription price (denominated in USD).
6. The smart contract verifies payment eligibility.
7. If valid, the contract pulls the funds automatically.

Everything runs through decentralized consensus via Chainlink CRE.

No centralized price server.  
No manual intervention.  
No single point of failure.

---

## Supported Tokens

Users can choose to pay in:

- **USDC**
- **WETH**
- **WBTC**

The subscription price is denominated in USD, and the workflow converts it into the correct token amount using consensus-verified price data.

---

## Use Cases

- Salaries paid in crypto
- Web3 SaaS subscriptions
- DAO recurring contributions
- Dollar Cost Averaging (DCA)
- B2B recurring invoices
- Tokenized rent payments

---

# Technical Description

## System Architecture

The system consists of:

1. Enterprise API
2. Price Data Endpoint
3. CRE Workflow
4. Payment Smart Contract

---

## 1. Enterprise API

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

## 2. Price Data Fetching

GET /api/tokenPrices
Example response:

```json
{
  "USDC": "1.00",
  "WETH": "3200.00",
  "WBTC": "60000.00"
}
```

This call is executed via CRE’s HTTP capability and validated through BFT consensus.
Multiple nodes independently fetch the prices and produce a verified aggregated result.
