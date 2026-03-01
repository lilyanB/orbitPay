export const OrbitPay = [
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "workflowExecutionId",
        type: "bytes32",
      },
      { internalType: "bytes", name: "data", type: "bytes" },
    ],
    name: "onReport",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;
