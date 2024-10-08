import { createSurfClient } from "@thalalabs/surf";
import { Account, Aptos, AptosConfig, Ed25519PrivateKey, Network } from "@aptos-labs/ts-sdk";
import { ABI } from "./abi.js";
import { generateStory, generateStoryCollision } from "./gradio.js";
import "dotenv/config";

export const aptos = new Aptos(new AptosConfig({ network: Network.TESTNET }));
export const surfClient = createSurfClient(aptos).useABI(ABI);

const appCreatorPrivateKey = process.env.APP_CREATOR_PRIVATE_KEY || '';

export async function createStoryDepot() {
  const result = await surfClient.entry.create_story_depot({
    account: Account.fromPrivateKey({ privateKey: new Ed25519PrivateKey(appCreatorPrivateKey) }),
    functionArguments: [],
    typeArguments: [],
  });
  return result;
}

export async function createStory(user: `0x${string}`, input: string) {
  const content = await generateStory(input);
  return await saveStory(user, input, content);
}

export async function createStoryCollision(user: `0x${string}`, input1: string, input2: string, story: string, story_id: number) {
  const content = await generateStoryCollision(input1, input2, story);
  return await saveStoryCollision(user, input1, input2, content, story_id);
}

async function saveStory(user: `0x${string}`, input: string, content: string) {
  const result = await surfClient.entry.create_story({
    account: Account.fromPrivateKey({ privateKey: new Ed25519PrivateKey(appCreatorPrivateKey) }),
    functionArguments: [user, input, content],
    typeArguments: [],
  });
  console.log(result);
  return { input, content };
}

async function saveStoryCollision(user: `0x${string}`, input1: string, input2: string, content: string, story_id: number) {
  const result = await surfClient.entry.create_story_collision({
    account: Account.fromPrivateKey({ privateKey: new Ed25519PrivateKey(appCreatorPrivateKey) }),
    functionArguments: [user, input1, input2, content, story_id],
    typeArguments: [],
  });
  console.log(result);
}

export async function getStory(address: `0x${string}`, index: string) {
  const [input, content] = await surfClient.view.get_story({
    functionArguments: [address, index],
    typeArguments: [],
  });
  return { input, content };
}

export async function listStory(address: `0x${string}`) {
  const storyList = await surfClient.view.list_story({
    functionArguments: [address],
    typeArguments: [],
  });
  return storyList;
}

export async function listStoryCollision(address: `0x${string}`) {
  const storyList = await surfClient.view.list_story_collision({
    functionArguments: [address],
    typeArguments: [],
  });
  return storyList;
}

export async function clearStoryDepot() {
  const result = await surfClient.entry.reset_app({
    account: Account.fromPrivateKey({ privateKey: new Ed25519PrivateKey(appCreatorPrivateKey) }),
    functionArguments: [],
    typeArguments: [],
  });
  return result;
}
