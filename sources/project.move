module MyModule::STEMCompetition {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a STEM competition
    struct Competition has store, key {
        total_participants: u64,     // Total number of participants
        max_participants: u64,        // Maximum number of participants allowed
        registration_fee: u64,        // Fee to register for the competition
        total_prize_pool: u64,        // Total prize money collected
        is_active: bool,              // Competition status
    }

    /// Create a new STEM competition with specified parameters
    public fun create_competition(
        organizer: &signer, 
        max_participants: u64, 
        registration_fee: u64
    ) {
        let competition = Competition {
            total_participants: 0,
            max_participants,
            registration_fee,
            total_prize_pool: 0,
            is_active: true
        };
        move_to(organizer, competition);
    }

    /// Allow participants to register for the competition
    public fun register_for_competition(
        participant: &signer, 
        competition_organizer: address
    ) acquires Competition {
        // Borrow the competition resource
        let competition = borrow_global_mut<Competition>(competition_organizer);
        
        // Check if competition is active and has space
        assert!(competition.is_active, 1);
        assert!(competition.total_participants < competition.max_participants, 2);

        // Collect registration fee
        let fee = competition.registration_fee;
        let registration_payment = coin::withdraw<AptosCoin>(participant, fee);
        coin::deposit<AptosCoin>(competition_organizer, registration_payment);

        // Update participant count and prize pool
        competition.total_participants = competition.total_participants + 1;
        competition.total_prize_pool = competition.total_prize_pool + fee;
    }
}