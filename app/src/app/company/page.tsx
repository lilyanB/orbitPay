"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useAccount, usePublicClient, useWriteContract } from "wagmi";
import { ConnectButton } from "@rainbow-me/rainbowkit";

import {
  ORBITPAY_FACTORY_ADDRESS,
  orbitPayFactoryAbi,
} from "../../lib/orbitPay";

function CompanyPage() {
  const { address, isConnected } = useAccount();
  const publicClient = usePublicClient();
  const { writeContractAsync } = useWriteContract();
  const [apiUrl, setApiUrl] = useState("");
  const [owner, setOwner] = useState("");
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const shortFactory = `${ORBITPAY_FACTORY_ADDRESS.slice(0, 6)}...${ORBITPAY_FACTORY_ADDRESS.slice(-4)}`;

  useEffect(() => {
    if (!owner && address) {
      setOwner(address);
    }
  }, [address, owner]);

  const handleCreate = async () => {
    if (!isConnected || !address || !publicClient || !owner) return;

    setLoading(true);
    try {
      // TODO: deploy workflow here and derive the CRE address from the workflow.
      const creAddress = owner;

      const hash = await writeContractAsync({
        address: ORBITPAY_FACTORY_ADDRESS,
        abi: orbitPayFactoryAbi,
        functionName: "createOrbitPay",
        args: [owner as `0x${string}`, creAddress as `0x${string}`],
      });
      await publicClient.waitForTransactionReceipt({ hash });
    } catch (error) {
      console.error("Create OrbitPay error", error);
    } finally {
      setLoading(false);
    }
  };

  const handleCopyFactory = async () => {
    try {
      await navigator.clipboard.writeText(ORBITPAY_FACTORY_ADDRESS);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 1500);
    } catch (error) {
      console.error("Copy failed", error);
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
        <h1 className="section-title">Company Space</h1>
        <div className="panel grid two">
          <div>
            <div className="label">API URL</div>
            <input
              type="url"
              placeholder="https://api.orbitpay.xyz/webhook"
              value={apiUrl}
              onChange={(event) => setApiUrl(event.target.value)}
            />
          </div>
          <div>
            <div className="label">Owner (receives funds)</div>
            <input
              type="text"
              placeholder="0x..."
              value={owner}
              onChange={(event) => setOwner(event.target.value)}
            />
          </div>
          <div>
            <button
              className="button secondary"
              type="button"
              onClick={handleCreate}
              disabled={!isConnected || loading || !owner}
            >
              {loading ? "Deploying..." : "Create an OrbitPay"}
            </button>
            <p className="footer-note">
              The workflow will be connected to the API URL later, then
              `createOrbitPay` will deploy the contract.
            </p>
          </div>
          <div
            className="panel"
            style={{ background: "transparent", boxShadow: "none" }}
          >
            <div className="label">Factory</div>
            <div className="grid two" style={{ alignItems: "center" }}>
              <div className="orbit-address">{shortFactory}</div>
              <button
                className="button ghost"
                type="button"
                onClick={handleCopyFactory}
              >
                {copied ? "Copied" : "Copy"}
              </button>
            </div>
            <div className="footer-note">Connect your wallet to deploy.</div>
          </div>
        </div>
      </section>
    </div>
  );
}

export default CompanyPage;
