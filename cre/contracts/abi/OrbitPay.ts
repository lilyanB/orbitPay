export const OrbitPay = [
  {
    inputs: [
      { internalType: "address[]", name: "users", type: "address[]" },
      { internalType: "uint256[]", name: "amounts", type: "uint256[]" },
    ],
    name: "pay",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;
