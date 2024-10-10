# Story Collision
<img src="https://github.com/diegocardoso93/story-collision/blob/main/story_collision.png?raw=true" width="256" height="256">

Let your AI-generated story collide with characters from other users' stories.  
Are you ready to cross the destinies?

## How it works
- **Create your story:** Insert personage name, attributes, likes and dislikes. 
- **Collide:** Select other user created personage story to collide.
- **Have fun reading:** Prepare to be amazed with the enchanting tales created and the crossed paths of the characters.

### Key Features:
- **On chain storage:** All stories are securely stored on-chain, linked to the creator's account for authenticity.  
- **Main Components:**  
  - **backend**  
[`Move`](https://aptos.dev/en/build/smart-contracts) smart contract definitions, entry and view methods.  
[`Thalalabs/Surf`](https://github.com/ThalaLabs/surf) lib to easy interact with Aptos contracts via ABI generated type definitions.  
Gradio to call Hugging Face [`yuntian-deng/ChatGPT4`](https://huggingface.co/spaces/yuntian-deng/ChatGPT4) LLM model.  
  - **frontend**  
Browser client application that integrates [`Petra Wallet`](https://petra.app/).  
