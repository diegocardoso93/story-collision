import { useEffect, useState } from 'react';
import { API_BASE_URL, Story } from './utils';
import './assets/Modal.css';

function ModalCollide({ selected, user, close }: Props) {
  const [stories, setStories] = useState<Story[]>([]);
  const [loading, setLoading] = useState<number>();

  useEffect(() => {
    async function getStoriesToCollide() {
      const response = await fetch(`${API_BASE_URL}/story`)
      const json = await response.json();
      const tstories = json[0] as Story[];
      tstories.sort((a, b) => b.story_id - a.story_id);
      setStories(tstories.filter(s => s.input != selected.input));
    }
    getStoriesToCollide();
  }, []);

  async function collide(story: Story) {
    setLoading(story.story_id);
    await fetch(`${API_BASE_URL}/collide`, {
      method: 'post',
      body: JSON.stringify({
        user,
        input1: selected.input,
        input2: story.input,
        story: selected.content,
        story_id1: selected.story_id,
        story_id2: story.story_id,
      }),
      headers: { 'Content-Type': 'application/json' }
    });
    setLoading(0);
    close();
  }

  return (
    <div className="modal overlay">
      <div className="content">
        <div className="close" onClick={() => close()}>&times;</div>
        {stories.map(s =>
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
  user: string | undefined,
  close: Function,
}

export default ModalCollide;
