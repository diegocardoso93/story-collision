# Story Collision
<img src="https://github.com/diegocardoso93/story-collision/blob/main/story_collision.png?raw=true" width="256" height="256">

Let your AI-generated story collide with characters from other users' stories.  
Are you ready to cross the destinies?

## How it works
- **Create a story:** Define your character’s name, attributes, likes, and dislikes.
- **Collide:** Choose a character from another user to create a unique narrative crossover.
- **Enjoy Reading:** Discover the intriguing tales that emerge from these character intersections.

### Key Features:
- **On chain storage:** All stories are securely stored on-chain, linked to the creator's account for authenticity.  
- **Main Components:**  
  - **backend**  
[`Move`](https://aptos.dev/en/build/smart-contracts) smart contract definitions, entry and view methods.  
[`Thalalabs/Surf`](https://github.com/ThalaLabs/surf) lib to easy interact with Aptos contracts via ABI generated type definitions.  
Gradio to call Hugging Face [`yuntian-deng/ChatGPT4`](https://huggingface.co/spaces/yuntian-deng/ChatGPT4) LLM model.  
  - **frontend**  
Browser client application that integrates [`Petra Wallet`](https://petra.app/).  
