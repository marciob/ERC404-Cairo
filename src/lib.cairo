#[starknet::interface]
trait IERC404<TContractState> {
    // Implement functions
}

#[starknet::contract]
mod ERC404 {
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {

    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        spender: ContractAddress,
        value: u256
    }

    #[storage]
    struct Storage {
        // Implement storage
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
    ) {
        // Implement constructor
    }

    #[abi(embed_v0)]
    impl ERC404Impl of super::IERC404<ContractState> {
        // Implement functions
    }
}


