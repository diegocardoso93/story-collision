module story_collision_addr::story_collision {
    use std::signer;
    use std::vector;
    use std::string::String;
    use aptos_std::smart_vector;

    const E_STORY_DEPOT_DOES_NOT_EXIST: u64 = 1;
    const E_STORY_DEPOT_ALREADY_CREATED: u64 = 2;
    const E_STORY_DOES_NOT_EXIST: u64 = 3;
    const E_STORY_COLLISION_ALREADY_EXISTS: u64 = 4;

    const PAGE_SIZE: u64 = 5;

    struct Story has store, drop, copy {
        story_id: u64,
        user: address,
        input: String,
        content: String,
    }

    struct StoryCollision has store, drop, copy {
        story_id1: u64,
        story_id2: u64,
        user: address,
        input1: String,
        input2: String,
        content: String,
    }

    struct StoryDepot has key {
        stories: smart_vector::SmartVector<Story>,
        stories_collisions: smart_vector::SmartVector<StoryCollision>,
        story_sequence: u64,
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
            stories: smart_vector::new<Story>(),
            stories_collisions: smart_vector::new<StoryCollision>(),
            story_sequence: 0,
        };
        // store the StoryDepot resource directly under the sender
        move_to(app, story_depot);
    }

    public entry fun create_story(app: &signer, user: address, input: String, content: String) acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let sequence = story_depot.story_sequence + 1;
        story_depot.story_sequence = sequence;
        let new_story = Story {
            story_id: sequence,
            user,
            input,
            content,
        };
        smart_vector::push_back(&mut story_depot.stories, new_story);
    }

    public entry fun create_story_collision(
        app: &signer,
        user: address,
        input1: String,
        input2: String,
        content: String,
        story_id1: u64,
        story_id2: u64
    ) acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        assert_story_collision_does_not_exists(app_address, story_id1, story_id2);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let new_story = StoryCollision {
            user,
            input1,
            input2,
            content,
            story_id1,
            story_id2,
        };
        smart_vector::push_back(&mut story_depot.stories_collisions, new_story);
    }

    public fun remove_story(app: &signer, story_id: u64): bool acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let length = smart_vector::length(&mut story_depot.stories);
        while (length > 0) {
            length = length - 1;
            let story = smart_vector::borrow(&story_depot.stories, length);
            if (story.story_id == story_id) {
                smart_vector::remove(&mut story_depot.stories, length);
                return true
            };
        };
        false
    }

    public fun remove_story_collision(app: &signer, story_id1: u64, story_id2: u64): bool acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let length = smart_vector::length(&mut story_depot.stories_collisions);
        while (length > 0) {
            length = length - 1;
            let story = smart_vector::borrow(&story_depot.stories_collisions, length);
            if (story.story_id1 == story_id1 && story.story_id2 == story_id2) {
                smart_vector::remove(&mut story_depot.stories_collisions, length);
                return true
            };
        };
        false
    }

    public entry fun clear_story(app: &signer) acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        story_depot.story_sequence = 0;
        smart_vector::clear(&mut story_depot.stories);
    }

    public entry fun clear_story_collision(app: &signer) acquires StoryDepot {
        let app_address = signer::address_of(app);
        assert_story_depot_has_created(app_address);
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        smart_vector::clear(&mut story_depot.stories_collisions);
    }

    public entry fun reset_app(app: &signer) acquires StoryDepot {
        clear_story(app);
        clear_story_collision(app);
    }

    // ======================== Read Functions ========================

    #[view]
    public fun has_story_depot(app_address: address): bool {
        exists<StoryDepot>(app_address)
    }

    #[view]
    public fun get_depot_lengths(app_address: address): (u64, u64) acquires StoryDepot {
        let story_depot = borrow_global<StoryDepot>(app_address);
        (smart_vector::length(&story_depot.stories), smart_vector::length(&story_depot.stories_collisions))
    }

    #[view]
    public fun list_story(app_address: address, page: u64): (vector<Story>, u64) acquires StoryDepot {
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let stories: vector<Story> = vector::empty();
        let length = smart_vector::length(&mut story_depot.stories);
        let stop = page * PAGE_SIZE;
        let start = stop - PAGE_SIZE;
        while (stop - start > 0 && start < length) {
            let story = smart_vector::borrow(&story_depot.stories, start);
            vector::push_back(&mut stories, *story);
            start = start + 1;
        };
        (stories, length)
    }

    #[view]
    public fun get_story(app_address: address, story_idx: u64): (address, String, String, u64) acquires StoryDepot {
        let story_depot = borrow_global<StoryDepot>(app_address);
        assert!(story_idx < smart_vector::length(&story_depot.stories), E_STORY_DOES_NOT_EXIST);
        let story_record = smart_vector::borrow(&story_depot.stories, story_idx);
        (story_record.user, story_record.input, story_record.content, story_record.story_id)
    }

    #[view]
    public fun list_story_collision(app_address: address, page: u64): (vector<StoryCollision>, u64) acquires StoryDepot {
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let stories_collisions: vector<StoryCollision> = vector::empty();
        let length = smart_vector::length(&mut story_depot.stories_collisions);
        let stop = page * PAGE_SIZE;
        let start = stop - PAGE_SIZE;
        while (stop - start > 0 && start < length) {
            let story_collision = smart_vector::borrow(&story_depot.stories_collisions, start);
            vector::push_back(&mut stories_collisions, *story_collision);
            start = start + 1;
        };
        (stories_collisions, length)
    }

    #[view]
    public fun list_user_story(app_address: address, user: address): vector<Story> acquires StoryDepot {
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let stories: vector<Story> = vector::empty();
        let length = smart_vector::length(&mut story_depot.stories);
        while (length > 0) {
            length = length - 1;
            let story = smart_vector::borrow(&story_depot.stories, length);
            if (story.user == user) {
                vector::push_back(&mut stories, *story);
            }
        };
        stories
    }

    #[view]
    public fun list_user_story_collision(app_address: address, user: address): vector<StoryCollision> acquires StoryDepot {
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let stories_collisions: vector<StoryCollision> = vector::empty();
        let length = smart_vector::length(&mut story_depot.stories_collisions);
        while (length > 0) {
            length = length - 1;
            let story_collision = smart_vector::borrow(&story_depot.stories_collisions, length);
            if (story_collision.user == user) {
                vector::push_back(&mut stories_collisions, *story_collision);
            }
        };
        stories_collisions
    }


    // ======================== Helper Functions ========================

    fun assert_story_depot_has_created(app_address: address) {
        assert!(
            exists<StoryDepot>(app_address),
            E_STORY_DEPOT_DOES_NOT_EXIST
        );
    }

    fun assert_story_collision_does_not_exists(app_address: address, story_id1: u64, story_id2: u64) acquires StoryDepot {
        let story_depot = borrow_global_mut<StoryDepot>(app_address);
        let length = smart_vector::length(&mut story_depot.stories_collisions);
        let found = false;
        while (length > 0) {
            length = length + 1;
            let story_collision = smart_vector::borrow(&story_depot.stories_collisions, length);
            if (story_collision.story_id1 == story_id1 && story_collision.story_id2 == story_id2) {
                found = true;
            }
        };

        assert!(
            !found,
            E_STORY_COLLISION_ALREADY_EXISTS
        );
    }

    // ======================== Unit Tests ========================

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_std::string_utils;
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
        let (story_length, story_collision_length) = get_depot_lengths(admin_addr);
        debug::print(&string_utils::format1(&b"story_length: {}", story_length));
        debug::print(&string_utils::format1(&b"story_collision_length: {}", story_collision_length));
        assert!(story_length == 1, 3);
        assert!(story_collision_length == 0, 4);

        let (story_address, story_input, story_content, story_id) = get_story(admin_addr, 0);
        debug::print(&string_utils::format1(&b"story.story_id: {}", story_id));
        debug::print(&string_utils::format1(&b"story.input: {}", story_input));
        debug::print(&string_utils::format1(&b"story.content: {}", story_content));
        assert!(story_address == @0x101, 5);
        assert!(story_input == string::utf8(b"input"), 6);
        assert!(story_content == string::utf8(b"content"), 7);

        // pagination test
        create_story(&admin, user, string::utf8(b"input1"), string::utf8(b"content1"));
        create_story(&admin, user, string::utf8(b"input2"), string::utf8(b"content2"));
        create_story(&admin, user, string::utf8(b"input3"), string::utf8(b"content3"));
        create_story(&admin, user, string::utf8(b"input4"), string::utf8(b"content4"));
        create_story(&admin, user, string::utf8(b"input5"), string::utf8(b"content5"));
        create_story(&admin, user, string::utf8(b"input6"), string::utf8(b"content6"));
        create_story(&admin, user, string::utf8(b"input7"), string::utf8(b"content7"));

        let (stories, total_length) = list_story(admin_addr, 1);
        assert!(vector::length(&stories) == 5, 8);
        assert!(total_length == 8, 9);
        let (stories, _) = list_story(admin_addr, 2);
        assert!(vector::length(&stories) == 3, 10);

        let removed = remove_story(&admin, 2);
        assert!(removed, 11);
        let (_, total_length) = list_story(admin_addr, 2);
        assert!(total_length == 7, 12);

        create_story_collision(&admin, user, string::utf8(b"input1"), string::utf8(b"input2"), string::utf8(b"content"), 1, 2);
        let (_, total_length) = list_story_collision(admin_addr, 1);
        assert!(total_length == 1, 13);

        let stories = list_user_story(admin_addr, user);
        assert!(vector::length(&stories) == 7, 14);
        let stories_collisions = list_user_story_collision(admin_addr, user);
        assert!(vector::length(&stories_collisions) == 1, 15);

        reset_app(&admin);
        let (_, len1) = list_story(admin_addr, 1);
        let (_, len2) = list_story_collision(admin_addr, 1);
        assert!(len1 == 0, 16);
        assert!(len2 == 0, 17);
    }

}
