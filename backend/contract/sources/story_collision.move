module story_collision_addr::story_collision {
    use std::signer;
    use std::vector;
    use std::string::String;

    const E_STORY_DEPOT_DOES_NOT_EXIST: u64 = 1;
    const E_STORY_DEPOT_ALREADY_CREATED: u64 = 2;
    const E_STORY_DOES_NOT_EXIST: u64 = 3;

    struct Story has store, drop, copy {
        story_id: u64,
        user: address,
        input: String,
        content: String,
    }

    struct StoryCollision has store, drop, copy {
        user: address,
        input1: String,
        input2: String,
        content: String,
        story_id: u64,
    }

    struct StoryDepot has key {
        stories: vector<Story>,
        stories_collisions: vector<StoryCollision>,
        story_counter: u64,
        story_collisions_counter: u64,
    }

    fun init_module(_module_publisher: &signer) {
        // nothing to do here
    }

    // ======================== Write functions ========================

    public entry fun create_story_depot(app: &signer) {
        let app_address = signer::address_of(app);
        assert!(
            !exists<StoryDepot>(app_address),
            E_STORY_DEPOT_ALREADY_CREATED
        );
        let story_depot = StoryDepot {
            stories: vector::empty(),
            stories_collisions: vector::empty(),
            story_counter: 0,
            story_collisions_counter: 0,
        };
        // store the StoryDepot resource directly under the sender
        move_to(app, story_depot);
    }

    public entry fun create_story(app: &signer, user: address, input: String, content: String) acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let counter = story_depot.story_counter + 1;
        story_depot.story_counter = counter;
        let new_story = Story {
            story_id: counter,
            user,
            input,
            content,
        };
        vector::push_back(&mut story_depot.stories, new_story);
    }

    public entry fun create_story_collision(app: &signer, user: address, input1: String, input2: String, content: String, story_id: u64) acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let new_story = StoryCollision {
            user,
            input1,
            input2,
            content,
            story_id
        };
        vector::push_back(&mut story_depot.stories_collisions, new_story);
    }

    public entry fun clear_story(app: &signer) acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let length = vector::length(&mut story_depot.stories);
        while (length > 0) {
            length = length - 1;
            vector::remove(&mut story_depot.stories, length);
        }
    }

    public entry fun clear_story_collision(app: &signer) acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let length = vector::length(&mut story_depot.stories_collisions);
        while (length > 0) {
            length = length - 1;
            vector::remove(&mut story_depot.stories_collisions, length);
        }
    }

    public entry fun reset_app(app: &signer) acquires StoryDepot {
        clear_story(app);
        clear_story_collision(app);
    }

    // ======================== Read Functions ========================

    #[view]
    public fun has_story_depot(app: address): bool {
        exists<StoryDepot>(app)
    }

    #[view]
    public fun get_story_depot(app: address): (u64) acquires StoryDepot {
        let story_depot = borrow_global<StoryDepot>(app);
        (vector::length(&story_depot.stories))
    }

    #[view]
    public fun list_story(app: address): vector<Story> acquires StoryDepot {
        let story_depot = borrow_global<StoryDepot>(app);
        let stories: vector<Story> = story_depot.stories;
        stories
    }

    #[view]
    public fun get_story(app: address, story_idx: u64): (address, String, String, u64) acquires StoryDepot {
        let story_depot = borrow_global<StoryDepot>(app);
        assert!(story_idx < vector::length(&story_depot.stories), E_STORY_DOES_NOT_EXIST);
        let story_record = vector::borrow(&story_depot.stories, story_idx);
        (story_record.user, story_record.input, story_record.content, story_record.story_id)
    }

    #[view]
    public fun list_story_collision(app: address): vector<StoryCollision> acquires StoryDepot {
        let story_depot = borrow_global<StoryDepot>(app);
        let stories_collisions: vector<StoryCollision> = story_depot.stories_collisions;
        stories_collisions
    }

    // ======================== Helper Functions ========================

    fun assert_story_depot_has_created(app_addr: address) {
        assert!(
            exists<StoryDepot>(app_addr),
            E_STORY_DEPOT_DOES_NOT_EXIST
        );
    }

    // ======================== Unit Tests ========================

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_std::string_utils;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_std::debug;

    #[test(admin = @0x100, user = @0x101)]
    public entry fun test_end_to_end(admin: signer, user: address) acquires StoryDepot {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        assert!(!has_story_depot(admin_addr), 1);
        create_story_depot(&admin);
        assert!(has_story_depot(admin_addr), 2);

        create_story(&admin, user, string::utf8(b"input"), string::utf8(b"content"));
        let (story_depot_length) = get_story_depot(admin_addr);
        debug::print(&string_utils::format1(&b"story_depot_length: {}", story_depot_length));
        assert!(story_depot_length == 1, 3);

        let (story_address, story_input, story_content, story_id) = get_story(admin_addr, 0);
        debug::print(&string_utils::format1(&b"story.story_id: {}", story_id));
        debug::print(&string_utils::format1(&b"story.input: {}", story_input));
        debug::print(&string_utils::format1(&b"story.content: {}", story_content));
        assert!(story_address == @0x101, 4);
        assert!(story_input == string::utf8(b"input"), 5);
        assert!(story_content == string::utf8(b"content"), 6);

        let stories = list_story(admin_addr);
        assert!(vector::length(&stories) == 1, 7);

        create_story_collision(&admin, user, string::utf8(b"input1"), string::utf8(b"input2"), string::utf8(b"content"), story_id);
        let stories_collisions = list_story_collision(admin_addr);
        assert!(vector::length(&stories_collisions) == 1, 8);

        reset_app(&admin);
        let stories = list_story(admin_addr);
        let stories_collisions = list_story_collision(admin_addr);
        assert!(vector::length(&stories) == 0, 9);
        assert!(vector::length(&stories_collisions) == 0, 10);
    }

}
