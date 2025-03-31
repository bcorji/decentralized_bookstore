use core::starknet::ContractAddress;

// Define the contract interface
#[starknet::interface]
trait IPurchase<TContractState> {
    fn buy_book(ref self: TContractState, bookstore_address: ContractAddress, book_id: u64, quantity: u8);
}

#[starknet::contract]
mod Purchase {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::starknet::ContractAddress;

    #[storage]
    struct Storage {
    }

    #[abi(embed_v0)]
    impl PurchaseImpl of super::IPurchase<ContractState> {
        fn buy_book(ref self: ContractState, bookstore_address: ContractAddress, book_id: u64, quantity: u8) {
            let available_quantity = IBookstoreDispatcher { contract_address: bookstore_address }.get_book_quantity(book_id);
            assert(available_quantity >= quantity, 'Not enough books available');

            // TODO: Implement logic to transfer tokens from the buyer to the bookstore owner.
            // For now, we'll just update the quantity in the bookstore contract.
            IBookstoreDispatcher { contract_address: bookstore_address }.update_book(book_id, 0, available_quantity - quantity);
        }
    }

    use core::starknet::get_caller_address;
    use super::IBookstoreDispatcherTrait;
}

