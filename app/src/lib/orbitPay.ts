export const ORBITPAY_FACTORY_ADDRESS =
  "0x06FC05829dfA3667f3089DFe9CF0e7d9D4e7C8C4" as const;

export const TOKEN_ADDRESSES = {
  USDC: "0x23a0485b021CA24efde51114823FDbA761359780",
  USDT: "0xa0a5a661f7fad0E1F5B5a9C479de51eEEf4D1223",
  WETH: "0x260B90dFf3F586B1141790a212D7437D5521d5B8",
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
    inputs: [{ name: "owner", type: "address" }],
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
  {
    type: "function",
    name: "getUserInfo",
    stateMutability: "view",
    inputs: [{ name: "user", type: "address" }],
    outputs: [
      {
        name: "userInfo_",
        type: "tuple",
        components: [
          { name: "token", type: "uint8" },
          { name: "lastPayment", type: "uint40" },
        ],
      },
    ],
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
  {
    type: "function",
    name: "allowance",
    stateMutability: "view",
    inputs: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
    ],
    outputs: [{ name: "remaining", type: "uint256" }],
  },
] as const;
