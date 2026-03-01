import {
  CronCapability,
  HTTPClient,
  type HTTPSendRequester,
  EVMClient,
  handler,
  consensusIdenticalAggregation,
  Runner,
  type Runtime,
  getNetwork,
  bytesToHex,
  hexToBase64,
  json,
} from "@chainlink/cre-sdk";
import { encodeAbiParameters, parseAbiParameters } from "viem";

type EvmConfig = {
  chainName: string;
  orbitPayAddress: string;
  gasLimit: string;
};

type Config = {
  schedule: string;
  mustPayUrl: string;
  evms: EvmConfig[];
};

type PaymentRequest = {
  address: string;
  amount: string;
};

type WorkflowResult = {
  paymentsProcessed: number;
  batches: number;
};

const BATCH_SIZE = 20;

const initWorkflow = (config: Config) => {
  const cron = new CronCapability();
  return [handler(cron.trigger({ schedule: config.schedule }), onCronTrigger)];
};

const onCronTrigger = (runtime: Runtime<Config>): WorkflowResult => {
  const evmConfig = runtime.config.evms[0];

  const network = getNetwork({
    chainFamily: "evm",
    chainSelectorName: evmConfig.chainName,
    isTestnet: true,
  });
  if (!network) {
    throw new Error(`Unknown chain: ${evmConfig.chainName}`);
  }

  // Step 1: Fetch the list of subscribers and amounts from the enterprise API
  const mustPayList = fetchMustPayList(runtime);
  runtime.log(`Fetched ${mustPayList.length} pending payments`);

  if (mustPayList.length === 0) {
    runtime.log("No payments due this cycle");
    return { paymentsProcessed: 0, batches: 0 };
  }

  // Step 2: Split into batches of at most BATCH_SIZE and call pay() for each batch
  const evmClient = new EVMClient(network.chainSelector.selector);
  const batches = chunk(mustPayList, BATCH_SIZE);

  runtime.log(
    `Processing ${mustPayList.length} payments in ${batches.length} batch(es)`,
  );

  for (let i = 0; i < batches.length; i++) {
    const batch = batches[i];
    const users = batch.map((r) => r.address as `0x${string}`);
    const amounts = batch.map((r) => BigInt(r.amount));

    runtime.log(`Batch ${i + 1}/${batches.length}: ${batch.length} entries`);

    const txHash = submitBatch(runtime, evmClient, evmConfig, users, amounts);
    runtime.log(`Batch ${i + 1} tx: ${txHash}`);
  }

  const result: WorkflowResult = {
    paymentsProcessed: mustPayList.length,
    batches: batches.length,
  };

  runtime.log(
    `Workflow complete — ${mustPayList.length} payments in ${batches.length} batch(es)`,
  );
  return result;
};

const fetchMustPayList = (runtime: Runtime<Config>): PaymentRequest[] => {
  const httpClient = new HTTPClient();
  return httpClient
    .sendRequest(
      runtime,
      (sendRequester: HTTPSendRequester) => {
        const resp = sendRequester
          .sendRequest({ url: runtime.config.mustPayUrl, method: "GET" })
          .result();
        return json(resp) as PaymentRequest[];
      },
      consensusIdenticalAggregation<PaymentRequest[]>(),
    )()
    .result();
};

const submitBatch = (
  runtime: Runtime<Config>,
  evmClient: EVMClient,
  evmConfig: EvmConfig,
  users: `0x${string}`[],
  amounts: bigint[],
): string => {
  const reportData = encodeAbiParameters(
    parseAbiParameters("address[] users, uint256[] amounts"),
    [users, amounts],
  );

  const report = runtime
    .report({
      encodedPayload: hexToBase64(reportData),
      encoderName: "evm",
      signingAlgo: "ecdsa",
      hashingAlgo: "keccak256",
    })
    .result();

  const writeResult = evmClient
    .writeReport(runtime, {
      receiver: evmConfig.orbitPayAddress,
      report,
      gasConfig: { gasLimit: evmConfig.gasLimit },
    })
    .result();

  const txHash = bytesToHex(writeResult.txHash || new Uint8Array(32));
  runtime.log(`View tx at https://sepolia.etherscan.io/tx/${txHash}`);
  return txHash;
};

// --- Split an array into fixed-size chunks ---

const chunk = <T>(arr: T[], size: number): T[][] => {
  const result: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    result.push(arr.slice(i, i + size));
  }
  return result;
};

// --- Entry point ---

export async function main() {
  const runner = await Runner.newRunner<Config>();
  await runner.run(initWorkflow);
}
