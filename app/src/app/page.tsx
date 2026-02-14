import Link from "next/link";
import { ConnectButton } from "@rainbow-me/rainbowkit";

function Page() {
  return (
    <div className="page">
      <header className="topbar">
        <Link className="brand" href="/">
          OrbitPay
        </Link>
        <ConnectButton />
      </header>

      <main className="hero">
        <div className="hero-text">
          <h1 className="hero-title">
            Recurring payments, simple and reliable.
          </h1>
          <p className="hero-subtitle">
            OrbitPay automates crypto subscriptions with secure workflows.
            Choose your role to get started.
          </p>
          <div className="cta-row">
            <Link className="cta" href="/user">
              User Space
            </Link>
            <Link className="cta secondary" href="/company">
              Company Space
            </Link>
          </div>
        </div>

        <div className="hero-card">
          <h2 className="card-title">What OrbitPay delivers</h2>
          <p className="card-text">
            OrbitPay contracts deployed by the factory, a clear token choice,
            and one-click approvals to stay ready to pay.
          </p>
        </div>
      </main>

      <section className="section">
        <h2 className="section-title">How the solution works</h2>
        <div className="solution-grid">
          <div className="diagram">
            <div className="diagram-card">
              <div className="diagram-title">Enterprise API</div>
              <div className="diagram-text">
                Returns who must pay and USD pricing.
              </div>
            </div>
            <div className="diagram-arrow">-&gt;</div>
            <div className="diagram-card">
              <div className="diagram-title">Chainlink CRE Workflow</div>
              <div className="diagram-text">
                Fetches prices and validates data by consensus.
              </div>
            </div>
            <div className="diagram-arrow">-&gt;</div>
            <div className="diagram-card">
              <div className="diagram-title">OrbitPay Factory</div>
              <div className="diagram-text">
                Deploys OrbitPay contracts per company.
              </div>
            </div>
            <div className="diagram-arrow">-&gt;</div>
            <div className="diagram-card">
              <div className="diagram-title">OrbitPay Contract</div>
              <div className="diagram-text">
                Pulls approved tokens from users on schedule.
              </div>
            </div>
          </div>

          <div className="panel">
            <h3 className="card-title">Key guarantees</h3>
            <p className="card-text">
              OrbitPay removes manual ops and central points of failure. Users
              pick USDC, USDT, or WETH, approve once, and the workflow triggers
              payments at the right time with verified prices.
            </p>
            <div className="pill-row">
              <span className="pill">Decentralized price checks</span>
              <span className="pill">Onchain transparency</span>
              <span className="pill">Subscription-ready UX</span>
            </div>
          </div>
        </div>
      </section>

      <footer className="footer">
        <div className="footer-left">
          <img
            className="footer-logo"
            src="/chainlink/Chainlink-Logo-Blue.png"
            alt="Chainlink"
          />
          <div>
            <div className="footer-title">OrbitPay Network</div>
            <div className="footer-text">Sepolia testnet deployment</div>
          </div>
        </div>
        <div className="footer-links">
          <a
            href="https://github.com/lilyanB/chainlink-cre"
            target="_blank"
            rel="noreferrer"
          >
            GitHub
          </a>
          <a href="https://chain.link" target="_blank" rel="noreferrer">
            Chainlink
          </a>
          <a
            href="https://sepolia.etherscan.io"
            target="_blank"
            rel="noreferrer"
          >
            Sepolia
          </a>
        </div>
      </footer>
    </div>
  );
}

export default Page;
