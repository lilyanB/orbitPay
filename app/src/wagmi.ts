import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { sepolia } from "wagmi/chains";

export const config = getDefaultConfig({
  appName: "orbitPay",
  projectId: "649dca8840ff87c9f048b2666a4cbf87",
  chains: [sepolia],
  ssr: true,
});
