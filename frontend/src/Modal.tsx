import { useEffect, useState } from 'react';
import './assets/Modal.css';

function ModalCollide({selected, stories, user, close}: any) {
  const [otherUsersStories, setOtherUsersStories] = useState<any>([]);
  const [loading, setLoading] = useState<number>();

  useEffect(() => {
    console.log(selected);
    setOtherUsersStories(stories.filter(s => s.input != selected.input));
  }, []);

  async function collide(story: any) {
    setLoading(story.story_id);
    await fetch('http://localhost:3000/collide', {
      method: 'post',
      body: JSON.stringify({ user, input1: selected.input, input2: story.input, story: selected.content, story_id: selected.story_id }),
      headers: {'Content-Type': 'application/json'}
    });
    setLoading(0);
    close();
  }

  return (
    <>
      <div className="modal overlay">
        <div className="content">
        <div className="close" onClick={close}>×</div>
          {otherUsersStories.map(s =>
            <div key={s.story_id} className="item">
              <p>{ s.input }</p>
              <div>
                <button onClick={() => collide(s)}>
                  {loading == s.story_id && <div className="loader xsmall"></div> || 'collide'}
                </button>
                </div>
            </div>)}
        </div>
      </div>
    </>
  )
}

export default ModalCollide;
