"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import {
  useAccount,
  usePublicClient,
  useReadContract,
  useReadContracts,
  useWriteContract,
} from "wagmi";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { maxUint256 } from "viem";

import {
  ORBITPAY_FACTORY_ADDRESS,
  TOKEN_ADDRESSES,
  erc20Abi,
  orbitPayAbi,
  orbitPayFactoryAbi,
} from "../../lib/orbitPay";

type TokenKey = keyof typeof TOKEN_ADDRESSES;

const tokenOptions: { label: string; value: TokenKey; id: bigint }[] = [
  { label: "USDC", value: "USDC", id: 0n },
  { label: "USDT", value: "USDT", id: 1n },
  { label: "WETH", value: "WETH", id: 2n },
];

function UserPage() {
  const { address, isConnected } = useAccount();
  const publicClient = usePublicClient();
  const { writeContractAsync } = useWriteContract();
  const [tokenChoice, setTokenChoice] = useState<Record<string, TokenKey>>({});
  const [loading, setLoading] = useState<Record<string, boolean>>({});

  const { data: orbitPayCount } = useReadContract({
    address: ORBITPAY_FACTORY_ADDRESS,
    abi: orbitPayFactoryAbi,
    functionName: "getOrbitPayId",
  });

  const orbitPayIds = useMemo(() => {
    const count = Number(orbitPayCount ?? 0n);
    return Array.from({ length: count }, (_, index) => BigInt(index));
  }, [orbitPayCount]);

  const { data: orbitPayResults } = useReadContracts({
    contracts: orbitPayIds.map((orbitPayId) => ({
      address: ORBITPAY_FACTORY_ADDRESS,
      abi: orbitPayFactoryAbi,
      functionName: "getOrbitPay",
      args: [orbitPayId],
    })),
    allowFailure: true,
  });

  const orbitPays = (orbitPayResults ?? [])
    .map((result) => result.result)
    .filter(Boolean) as unknown as `0x${string}`[];

  // Read user info for each OrbitPay
  const { data: userInfoResults } = useReadContracts({
    contracts: orbitPays.map((orbitPay) => ({
      address: orbitPay,
      abi: orbitPayAbi,
      functionName: "getUserInfo",
      args: address ? [address] : undefined,
    })),
    allowFailure: true,
    query: {
      enabled: isConnected && orbitPays.length > 0,
    },
  });

  // Read allowances for each OrbitPay - check all tokens
  const { data: allowanceResults } = useReadContracts({
    contracts: orbitPays.flatMap((orbitPay) => {
      if (!address) return [];

      return Object.values(TOKEN_ADDRESSES).map((tokenAddress) => ({
        address: tokenAddress as `0x${string}`,
        abi: erc20Abi,
        functionName: "allowance",
        args: [address, orbitPay],
      }));
    }),
    allowFailure: true,
    query: {
      enabled: isConnected && orbitPays.length > 0,
    },
  });

  const handleSubscribe = async (orbitPay: `0x${string}`) => {
    if (!isConnected || !address || !publicClient) return;

    const orbitPayKey = String(orbitPay);
    const tokenKey = tokenChoice[orbitPayKey] ?? "USDC";
    const tokenMeta =
      tokenOptions.find((item) => item.value === tokenKey) ?? tokenOptions[0];
    const tokenAddress = TOKEN_ADDRESSES[tokenMeta.value];

    setLoading((prev) => ({ ...prev, [orbitPayKey]: true }));
    try {
      const chosenHash = await writeContractAsync({
        address: orbitPay,
        abi: orbitPayAbi,
        functionName: "chosenToken",
        args: [tokenMeta.id],
      });
      await publicClient.waitForTransactionReceipt({ hash: chosenHash });

      const approveHash = await writeContractAsync({
        address: tokenAddress,
        abi: erc20Abi,
        functionName: "approve",
        args: [orbitPay, maxUint256],
      });
      await publicClient.waitForTransactionReceipt({ hash: approveHash });
    } catch (error) {
      console.error("Subscription error", error);
    } finally {
      setLoading((prev) => ({ ...prev, [orbitPayKey]: false }));
    }
  };

  return (
    <div className="page">
      <header className="topbar">
        <Link className="brand" href="/">
          OrbitPay
        </Link>
        <ConnectButton />
      </header>

      <section className="section">
        <h1 className="section-title">User Space</h1>
        <div className="panel">
          <div className="label">OrbitPay Factory</div>
          <div className="orbit-address">{ORBITPAY_FACTORY_ADDRESS}</div>
        </div>
      </section>

      <section className="section">
        <h2 className="section-title">Available contracts</h2>
        <div className="orbit-list">
          {orbitPays.length === 0 ? (
            <div className="panel">No OrbitPay deployed yet.</div>
          ) : (
            orbitPays.map((orbitPay, index) => {
              const choice = tokenChoice[String(orbitPay)] ?? "USDC";
              const userInfo = userInfoResults?.[index]?.result as
                | { token: number; lastPayment: bigint }
                | undefined;

              // Check allowances for all tokens
              const tokenKeys = Object.keys(TOKEN_ADDRESSES) as TokenKey[];
              const orbitPayAllowances = tokenKeys.map((_, tokenIndex) => {
                const allowanceIndex = index * tokenKeys.length + tokenIndex;
                return allowanceResults?.[allowanceIndex]?.result as
                  | bigint
                  | undefined;
              });

              // Find if user has approved any token
              let subscribedTokenKey: TokenKey | null = null;
              let hasApproved = false;

              for (let i = 0; i < orbitPayAllowances.length; i++) {
                if (orbitPayAllowances[i] && orbitPayAllowances[i]! > 0n) {
                  subscribedTokenKey = tokenKeys[i];
                  hasApproved = true;
                  break;
                }
              }

              const hasSubscribed = subscribedTokenKey !== null;

              return (
                <div className="orbit-item" key={orbitPay}>
                  <div className="orbit-address">{orbitPay}</div>

                  {hasSubscribed ? (
                    <div className="grid two">
                      <div>
                        <div className="label">Subscribed with</div>
                        <div className="token-display">
                          ✓ {subscribedTokenKey}
                        </div>
                      </div>
                      <div>
                        <div className="label">Approval status</div>
                        <div className="token-display">
                          {hasApproved ? "✓ Approved (max)" : "Not approved"}
                        </div>
                      </div>
                    </div>
                  ) : (
                    <>
                      <div className="grid two">
                        <div>
                          <div className="label">Payment token</div>
                          <select
                            value={choice}
                            onChange={(event) =>
                              setTokenChoice((prev) => ({
                                ...prev,
                                [String(orbitPay)]: event.target
                                  .value as TokenKey,
                              }))
                            }
                          >
                            {tokenOptions.map((option) => (
                              <option key={option.value} value={option.value}>
                                {option.label}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <div className="label">Action</div>
                          <button
                            className="button"
                            type="button"
                            onClick={() => handleSubscribe(orbitPay)}
                            disabled={!isConnected || loading[String(orbitPay)]}
                          >
                            {loading[orbitPay]
                              ? "Processing..."
                              : "Subscribe + Approve max"}
                          </button>
                        </div>
                      </div>
                      {!isConnected && (
                        <span className="badge">Connect your wallet</span>
                      )}
                    </>
                  )}
                </div>
              );
            })
          )}
        </div>
        <p className="footer-note">
          The subscription stores your token via `chosenToken` and approves the
          contract for recurring payments.
        </p>
      </section>
    </div>
  );
}

export default UserPage;
