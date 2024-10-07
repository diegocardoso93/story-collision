import { FormEvent, useEffect, useState } from 'react';
import { useWallet, WalletName } from '@aptos-labs/wallet-adapter-react';
import { API_BASE_URL, nl2br, Story, StoryCollision } from './utils';
import ModalCollide from './Modal';
import './assets/App.css';

function App() {
  const [currentView, setCurrentView] = useState<string>('new')
  const [newStory, setNewStory] = useState<{input: string, content: string}|null>();
  const [stories, setStories] = useState<Story[]>([]);
  const [myStories, setMyStories] = useState<Story[]>([]);
  const [collisions, setCollisions] = useState<StoryCollision[]>([]);
  const [selectedModalCollide, setSelectedModalCollide] = useState<Story|null>();
  const [loading, setLoading] = useState<boolean>();
  const { account, connect, connected } = useWallet();

  useEffect(() => {
    if (!connected) {
      connect("Petra" as WalletName<"Petra">);
    }
    setNewStory(null);
  }, [connected, currentView]);

  function goNew() {
    setCurrentView('new');
  }

  async function goMyStories() {
    setCurrentView('my');
    const response = await fetch(`${API_BASE_URL}/story`)
    const json = await response.json();
    const tstories = json[0] as Story[];
    tstories.sort((a, b) => b.story_id - a.story_id);
    setMyStories(tstories.filter((s) => s.user == account?.address));
    setStories(tstories);
  }

  async function goCollisions() {
    setCurrentView('collisions');
    const response = await fetch(`${API_BASE_URL}/collide`)
    const json = await response.json();
    const tstories = json[0] as StoryCollision[];
    tstories.sort((a, b) => b.story_id - a.story_id);
    setCollisions(tstories);
  }

  async function generate(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);

    let arrData = [];
    const inputs = (e.target as HTMLElement).querySelectorAll('input');
    for (let input of inputs) {
      arrData.push(`${input.id}: ${input.value}`);
    }

    const response = await fetch(`${API_BASE_URL}/story`, {
      method: 'post',
      body: JSON.stringify({ user: account?.address, input: arrData.join('; ') }),
      headers: {'Content-Type': 'application/json'}
    });
    const json = await response.json() as Story;

    setNewStory({input: json.input, content: json.content});
    setLoading(false);

    for (let input of inputs) {
      input.value = '';
    }
  }

  return (
    <>
      <div className="nav">
        <button
          className={`button-top ${currentView === 'new' && 'selected'}`}
          onClick={goNew}>
            new
        </button>
        <button
          className={`button-top ${currentView === 'my' && 'selected'}`}
          onClick={goMyStories}>
            my stories
        </button>
        <button
          className={`button-top ${currentView === 'collisions' && 'selected'}`}
          onClick={goCollisions}>
            collisions
        </button>
      </div>

      {currentView === 'new' && (
        <section id="generate">
          <form className="gcontainer" onSubmit={generate}>
            <label htmlFor="name">name:&nbsp;
              <input id="name" className="in" type="text" />
            </label>
            <label htmlFor="attributes">attributes:&nbsp;
              <input id="attributes" className="in" type="text" />
            </label>
            <label htmlFor="likes">likes:&nbsp;
              <input id="likes" className="in" type="text" />
            </label>
            <label htmlFor="dislikes">dislikes:&nbsp;
              <input id="dislikes" className="in" type="text" />
            </label>
            <button className="button-send">
              {loading && <div className="loader xsmall"></div> || 'generate'}
            </button>
          </form>

          {newStory?.input && (
            <article>
              <div className="top">
                <p className="title">{newStory?.input}</p>
              </div>
              <p dangerouslySetInnerHTML={{ __html: nl2br(newStory?.content) }}></p>
            </article>)}
        </section>
      )}

      {currentView === 'my' && (
        <section id="my">
          {myStories.map(x => 
            <article key={x.story_id}>
              <div className="top">
                <p className="title">{x.input}</p>
                <div>
                  <button className="button-collide" onClick={() => setSelectedModalCollide(x)}>
                    collide
                  </button>
                </div>
              </div>
              <p dangerouslySetInnerHTML={{ __html: nl2br(x.content) }}></p>
            </article>
          )}
        </section>
      )}

      {currentView === 'collisions' && (
        <section id="collisions">
          {collisions.map(x =>
            <article key={x.story_id}>
              <div className="top">
                <p className="title">{x.input1} <br/> {x.input2}</p>
              </div>
              <p dangerouslySetInnerHTML={{ __html: nl2br(x.content) }}></p>
            </article>
          )}
        </section>
      )}

      {selectedModalCollide && (
        <ModalCollide
          selected={selectedModalCollide}
          stories={stories}
          user={account?.address}
          close={() => setSelectedModalCollide(null)}
        />
      )}
    </>
  );
}

export default App;
