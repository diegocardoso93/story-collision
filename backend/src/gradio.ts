import { Client } from "@gradio/client";

// Name: Mario; Gender: Male; Passions: Dog, Rock; Fears: Heights, Deep waters
// name: Lary; attributes: female, low; likes: hula hoop, pure air; dislikes: smoke, bad smells
// Name: Beth; Gender: Female; Passions: Tailor Swift, Swimming; Fears: Clown, Screams

export async function generateStory(input: string) {
  const app = await Client.connect("yuntian-deng/ChatGPT4");

  const message = `Write a short story knowing the following information: "${input}"`;

  let result = await app.predict("/predict", {
    inputs: message,
    top_p: 1,
    temperature: 1,
    chat_counter: 0,
    chatbot: [],
  }) as Result;

  const text = result.data[0][0][1];
  console.log(text);
  return text;
}

export async function generateStoryCollision(input1: string, input2: string, story: string) {
  const app = await Client.connect("yuntian-deng/ChatGPT4");

  const message = `Considering the story of "${input1}"
Continue this story adding the encounter between the character described and this one: "${input2}"
Story: ${story}`;

  let result = await app.predict("/predict", {
    inputs: message,
    top_p: 1,
    temperature: 1,
    chat_counter: 0,
    chatbot: [],
  }) as Result;

  const text = result.data[0][0][1];
  console.log(text);
  return text;
}

type Result = {
  data: [[any]]
}
