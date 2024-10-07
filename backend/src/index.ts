import express, { NextFunction, Request, Response } from "express";
import cors from "cors";
import { clearStoryDepot, createStoryDepot, createStory, createStoryCollision, listStory, listStoryCollision } from "./chain";
import "dotenv/config";

// Create Express server
export const app = express();
const port = process.env.PORT || 3000;
const contactCreatorAccount = process.env.CONTRACT_CREATOR_ACCOUNT as `0x{string}`;

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
  res.send(await listStory(contactCreatorAccount));
});

app.post("/story", async (req: Request, res: Response) => {
  res.send(await createStory(req.body.user, req.body.input));
});


app.get("/collide", async (req: Request, res: Response) => {
  res.send(await listStoryCollision(contactCreatorAccount));
});

app.post("/collide", async (req: Request, res: Response) => {
  res.send(await createStoryCollision(req.body.user, req.body.input1, req.body.input2, req.body.story, req.body.story_id));
});

app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error(err.stack)
  res.status(500).send("Something broke!")
});

// Start server
app.listen(port, () => {
  console.log(`⚡️[server]: Server is running at http://localhost:${port}`)
});
