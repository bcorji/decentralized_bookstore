use core::starknet::ContractAddress;

// Define the contract interface
#[starknet::interface]
trait IBookstore<TContractState> {
    fn add_book(ref self: TContractState, title: felt252, author: felt252, description: felt252, price: u16, quantity: u8);
    fn update_book(ref self: TContractState, book_id: u64, price: u16, quantity: u8);
    fn remove_book(ref self: TContractState, book_id: u64);
    fn get_book(self: @TContractState, book_id: u64) -> (felt252, felt252, felt252, u16, u8);
    fn get_book_quantity(self: @TContractState, book_id: u64) -> u8;
}

#[starknet::contract]
mod Bookstore {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::starknet::ContractAddress;

    #[storage]
    struct Storage {
        books: Map<u64, Book>,
        book_count: u64,
        owner: ContractAddress,
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct Book {
        title: felt252,
        author: felt252,
        description: felt252,
        price: u16,
        quantity: u8,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
        self.book_count.write(0);
    }

    #[abi(embed_v0)]
    impl BookstoreImpl of super::IBookstore<ContractState> {
        fn add_book(ref self: ContractState, title: felt252, author: felt252, description: felt252, price: u16, quantity: u8) {
            assert(self.owner.read() == get_caller_address(), 'Not the owner');
            let book_id = self.book_count.read();
            self.books.insert(book_id, Book { title, author, description, price, quantity });
            self.book_count.write(book_id + 1);
        }

        fn update_book(ref self: ContractState, book_id: u64, price: u16, quantity: u8) {
            assert(self.owner.read() == get_caller_address(), 'Not the owner');
            assert(self.books.contains(book_id), 'Book does not exist');
            let mut book = self.books.get(book_id).unwrap();
            book.price = price;
            book.quantity = quantity;
            self.books.insert(book_id, book);
        }

        fn remove_book(ref self: ContractState, book_id: u64) {
            assert(self.owner.read() == get_caller_address(), 'Not the owner');
            assert(self.books.contains(book_id), 'Book does not exist');
            self.books.remove(book_id);
        }

        fn get_book(self: @ContractState, book_id: u64) -> (felt252, felt252, felt252, u16, u8) {
            match self.books.get(book_id) {
                Option::Some(book) => (book.title, book.author, book.description, book.price, book.quantity),
                Option::None => ('', '', '', 0, 0),
            }
        }

        fn get_book_quantity(self: @ContractState, book_id: u64) -> u8 {
             match self.books.get(book_id) {
                Option::Some(book) => book.quantity,
                Option::None => 0,
            }
        }
    }

    use core::starknet::get_caller_address;
    use core::starknet::storage::Map;
}

