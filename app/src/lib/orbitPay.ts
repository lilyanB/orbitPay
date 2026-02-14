export const ORBITPAY_FACTORY_ADDRESS =
  "0x5000d039abcf49238Bab7ecd60D276a2Cda7C2D0" as const;

export const TOKEN_ADDRESSES = {
  USDC: "0x6e13B503bE2d289dfE762ef29A3b19377946236b",
  USDT: "0xd2ECba4dFaE14CcE2d2e767974C01532C1f7EA07",
  WETH: "0x40e43BE2fEaf21cB459C4f493c14F0ad4A0E3451",
} as const;

export const orbitPayFactoryAbi = [
  {
    type: "function",
    name: "getOrbitPayId",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "orbitPayId_", type: "uint256" }],
  },
  {
    type: "function",
    name: "getOrbitPay",
    stateMutability: "view",
    inputs: [{ name: "orbitPayId", type: "uint256" }],
    outputs: [{ name: "orbitPay_", type: "address" }],
  },
  {
    type: "function",
    name: "createOrbitPay",
    stateMutability: "nonpayable",
    inputs: [
      { name: "owner", type: "address" },
      { name: "cre", type: "address" },
    ],
    outputs: [{ name: "orbitPay_", type: "address" }],
  },
] as const;

export const orbitPayAbi = [
  {
    type: "function",
    name: "chosenToken",
    stateMutability: "nonpayable",
    inputs: [{ name: "token", type: "uint256" }],
    outputs: [{ name: "token_", type: "address" }],
  },
] as const;

export const erc20Abi = [
  {
    type: "function",
    name: "approve",
    stateMutability: "nonpayable",
    inputs: [
      { name: "spender", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    outputs: [{ name: "success", type: "bool" }],
  },
] as const;
