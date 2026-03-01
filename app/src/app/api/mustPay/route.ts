import { NextResponse } from "next/server";

export function GET() {
  return NextResponse.json([
    {
      address: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      amount: "10000000",
    },
    {
      address: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
      amount: "20000000",
    },
    {
      address: "0x607A577659Cad2A2799120DfdEEde39De2D38706",
      amount: "30000000",
    },
  ]);
}
