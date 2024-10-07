
export function nl2br(text: string) {
  return text.replaceAll('\n', '<br/>');
}

export type Story = {
  story_id: number,
  user: string,
  input: string,
  content: string,
};

export type StoryCollision = {
  story_id: number,
  user: string,
  input1: string,
  input2: string,
  content: string,
};

export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;
