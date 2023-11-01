// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Library {
    address public owner;
    
    struct Book {
        uint256 id;
        string title;
        string author;
        address currentHolder;
        bool isAvailable;
    }
    
    mapping(uint256 => Book) public books;
    uint256 public bookCount;
    
    mapping(address => uint256[]) public userBooks;

    event BookAdded(uint256 bookId, string title, string author);
    event BookBorrowed(uint256 bookId, address borrower);
    event BookReturned(uint256 bookId, address borrower);

    constructor() {
        owner = msg.sender;
        bookCount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function addBook(string memory _title, string memory _author) public onlyOwner {
        bookCount++;
        books[bookCount] = Book(bookCount, _title, _author, address(this), true);
        emit BookAdded(bookCount, _title, _author);
    }

    function borrowBook(uint256 _bookId) public {
        require(_bookId > 0 && _bookId <= bookCount, "Invalid book ID");
        require(books[_bookId].isAvailable, "Book is not available");
        
        books[_bookId].isAvailable = false;
        books[_bookId].currentHolder = msg.sender;
        userBooks[msg.sender].push(_bookId);
        emit BookBorrowed(_bookId, msg.sender);
    }

    function returnBook(uint256 _bookId) public {
        require(_bookId > 0 && _bookId <= bookCount, "Invalid book ID");
        require(books[_bookId].currentHolder == msg.sender, "You do not have this book");

        books[_bookId].isAvailable = true;
        books[_bookId].currentHolder = address(this);
        emit BookReturned(_bookId, msg.sender);
    }

    function getUserBooks() public view returns (uint256[] memory) {
        return userBooks[msg.sender];
    }
}
