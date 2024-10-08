import { useEffect, useState } from 'react';
import { API_BASE_URL, Story } from './utils';
import './assets/Modal.css';

function ModalCollide({ selected, stories, user, close }: Props) {
  const [otherUsersStories, setOtherUsersStories] = useState<Story[]>([]);
  const [loading, setLoading] = useState<number>();

  useEffect(() => {
    setOtherUsersStories(stories.filter(s => s.input != selected.input));
  }, []);

  async function collide(story: Story) {
    setLoading(story.story_id);
    await fetch(`${API_BASE_URL}/collide`, {
      method: 'post',
      body: JSON.stringify({ user, input1: selected.input, input2: story.input, story: selected.content, story_id: selected.story_id }),
      headers: { 'Content-Type': 'application/json' }
    });
    setLoading(0);
    close();
  }

  return (
    <div className="modal overlay">
      <div className="content">
        <div className="close" onClick={() => close()}>&times;</div>
        {otherUsersStories.map(s =>
          <div key={s.story_id} className="item">
            <p>{s.input}</p>
            <div>
              <button onClick={() => collide(s)}>
                {loading == s.story_id && <div className="loader xsmall"></div> || 'collide'}
              </button>
            </div>
          </div>)}
      </div>
    </div>
  );
}

type Props = {
  selected: Story,
  stories: Story[],
  user: string | undefined,
  close: Function,
}

export default ModalCollide;
