# Story Collision
 ![logo](https://github.com/diegocardoso93/story-collision/blob/main/story_collision.png?raw=true)  
Let's your AI generated story collides with other users AI generated stories.  
Are you ready to cross the destinies?

## How it works
- **Create your story:** insert personage name, attributes, likes and dislikes. 
- **Collide:** Select other user created story to collide.
- **Have fun reading!** Prepare to be amazed and let your imagination flourish with the enchanting tales created and the crossed paths of the characters.
- **On chain storage:** All stories are stored on-chain with a reference to user creator account.

## Components

#### backend
Move Contract definitions, entry and view methods  
Uses Gradio to call Hugging Face `yuntian-deng/ChatGPT4` model  

#### frontend
Browser Client Application that integrates `Petra Wallet`  
