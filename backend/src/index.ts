import express, { NextFunction, Request, Response } from "express";
import cors from "cors";
import { clearStoryDepot, createStoryDepot, createStory, createStoryCollision, listStory, listStoryCollision, listUserStory } from "./chain";
import "dotenv/config";

// Create Express server
export const app = express();
const port = process.env.PORT || 3000;
const contractCreatorAccount = process.env.CONTRACT_CREATOR_ACCOUNT as `0x{string}`;

// Express configuration
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

// (async () => await createStoryDepot())()
// (async () => await clearStoryDepot())()

app.get("/", (req: Request, res: Response) => {
  console.log("GET /");
  res.send("index");
});

app.get("/story", async (req: Request, res: Response) => {
  const user = req.query.user as `0x{string}`;
  const page = +(req.query.page || 1);
  if (user) {
    return res.send(await listUserStory(contractCreatorAccount, user));
  }
  res.send(await listStory(contractCreatorAccount, page));
});

app.post("/story", async (req: Request, res: Response) => {
  res.send(await createStory(req.body.user, req.body.input));
});


app.get("/collide", async (req: Request, res: Response) => {
  const user = req.query.user as `0x{string}`;
  res.send(await listStoryCollision(contractCreatorAccount, user));
});

app.post("/collide", async (req: Request, res: Response) => {
  const { user, input1, input2, story, story_id1, story_id2 } = req.body;
  res.send(await createStoryCollision(user, input1, input2, story, story_id1, story_id2));
});

app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error(err.stack)
  res.status(500).send("Something broke!")
});

// Start server
app.listen(port, () => {
  console.log(`⚡️[server]: Server is running at http://localhost:${port}`)
});
