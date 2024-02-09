use starknet::ContractAddress;

#[starknet::interface]
trait IERC404<TContractState> {
    Fungible Token Functions (ERC20-like)
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;

    // Non-Fungible Token Functions (ERC721-like)
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn approve_nft(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn transfer_nft(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    );
    fn token_uri(self: @TContractState, token_id: u256) -> felt252;

    fn set_whitelist(ref self: TContractState, target: ContractAddress, state: bool);
}

#[starknet::contract]
mod ERC404 {
    use core::num::traits::zero::Zero;
use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {}

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
        // Metadata
        // /// @dev Token name
        // string public name;
        ERC404_name: felt252,
        // /// @dev Token symbol
        // string public symbol;
        ERC404_symbol: felt252,
        // /// @dev Decimals for fractional representation
        // uint8 public immutable decimals;
        ERC404_decimals: u8,
        // /// @dev Total supply in fractionalized representation
        // uint256 public immutable totalSupply;
        ERC404_total_supply: u256,
        // /// @dev Contract Owner
        ERC404_owner: ContractAddress,
        // /// @dev Current mint counter, monotonically increasing to ensure accurate ownership
        // uint256 public minted;
        ERC404_minted: u256,
        // // Mappings
        // /// @dev Balance of user in fractional representation
        // mapping(address => uint256) public balanceOf;
        ERC404_balances: LegacyMap<ContractAddress, u256>,
        // /// @dev Allowance of user in fractional representation
        // mapping(address => mapping(address => uint256)) public allowance;
        ERC404_allowances: LegacyMap<(ContractAddress, ContractAddress), u256>,
        // /// @dev Approval in native representaion
        // mapping(uint256 => address) public getApproved;
        ERC404_get_approved: LegacyMap<u256, ContractAddress>,
        // /// @dev Approval for all in native representation
        // mapping(address => mapping(address => bool)) public isApprovedForAll;
        ERC404_is_approved_for_all: LegacyMap<(ContractAddress, ContractAddress), bool>,
        // /// @dev Owner of id in native representation
        // mapping(uint256 => address) internal _ownerOf;
        ERC404_owner_of: LegacyMap<u256, ContractAddress>,
        // /// @dev Array of owned ids in native representation
        // mapping(address => uint256[]) internal _owned;
        //TODO: Check the best way to implement this in Cairo
        // ERC404_owned: LegacyMap<ContractAddress, Array<u256>>,

        // /// @dev Tracks indices for the _owned mapping
        // mapping(uint256 => uint256) internal _ownedIndex;
        ERC404_owned_index: LegacyMap<u256, u256>,
        // /// @dev Addresses whitelisted from minting / burning for gas savings (pairs, routers, etc)
        // mapping(address => bool) public whitelist;
        ERC404_whitelist: LegacyMap<ContractAddress, bool>,
    }
    // Implement constructor
    #[constructor]
    fn constructor(
        ref self: ContractState,
        // string memory _name,
        _name: felt252,
        // string memory _symbol,
        _symbol: felt252,
        // uint8 _decimals,
        _decimals: u8,
        // uint256 _totalNativeSupply,
        _totalNativeSupply: u256,
        // address _owner
        _owner: ContractAddress,
    ) {
        self.ERC404_name.write(_name);
        self.ERC404_symbol.write(_symbol);
        self.ERC404_decimals.write(_decimals);
        // TODO: Implement POW for 10**_decimals
        self.ERC404_total_supply.write(_totalNativeSupply * (10));
        self.ERC404_owner.write(_owner);
    }

    #[abi(embed_v0)]
    impl ERC404Impl of super::IERC404<ContractState> {
        // Implement functions

        // manage whitelist addresses
        fn set_whitelist(ref self: ContractState, target: ContractAddress, state: bool) {
            self.assert_only_owner();
            self.ERC404_whitelist.write(target, state);
        }


    }


    // INTERNAL FUNCTIONS
    #[generate_trait]
    impl Internal of InternalTrait {

        // Assert contract owner is calling
        fn assert_only_owner(self: @ContractState) {
            let owner = self.ERC404_owner.read();
            let caller = get_caller_address();
            assert(caller.is_non_zero(), 'Caller is the zero address');
            assert(caller == owner, 'Caller is not the owner');
        }
    }
}