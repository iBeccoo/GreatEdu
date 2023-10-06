// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

// error
error Book__NotOwner();
error Book__NotAdmin();
error Book__AlreadyAdmin();

contract Book {
    using Strings for uint256;
    // state variable
    address public immutable i_owner;
    address[] public s_admins;
    mapping(address => bool) s_isAdmin;

    struct BookData {
        uint256 bookIndex;
        string ISBN;
        string title;
        string year;
        string author;
    }
    BookData[] public s_bookDatas;
    mapping(string => BookData) public s_ISBNtoBookData;
    uint256 s_bookCount;

    //event
    event AddBook(address indexed sender, string indexed ISBN);
    event UpdateBook(
        address indexed sender,
        string indexed ISBN,
        string newTitle,
        string newYear,
        string newAuthor
    );
    event DeleteBook(address indexed sender, string indexed ISBN);

    // modifier
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Book__NotOwner();
        }
        _;
    }

    modifier onlyAdmin() {
        console.log(s_isAdmin[msg.sender]);
        if (!s_isAdmin[msg.sender]) {
            revert Book__NotAdmin();
        }
        _;
    }

    // function
    constructor() {
        i_owner = msg.sender;
    }

    function addAdmin(address _admin) external onlyOwner {
        if (s_isAdmin[_admin]) {
            revert Book__AlreadyAdmin();
        }

        s_admins.push(_admin);
        s_isAdmin[_admin] = true;
    }

    function getBook(
        string calldata _ISBN
    )
        external
        view
        returns (string memory title, string memory year, string memory author)
    {
        BookData memory bookData = s_ISBNtoBookData[_ISBN];

        return (bookData.title, bookData.year, bookData.author);
    }

    function addBook(
        string calldata _title,
        string calldata _year,
        string calldata _author
    ) external onlyAdmin {
        BookData memory bookData = BookData(
            getBookCount(),
            getISBN(_title, _year, _author),
            _title,
            _year,
            _author
        );
        s_ISBNtoBookData[bookData.ISBN] = bookData;
        s_bookDatas.push(bookData);
        s_bookCount++;

        emit AddBook(msg.sender, bookData.ISBN);
    }

    function updateBook(
        string calldata _ISBN,
        string calldata _title,
        string calldata _year,
        string calldata _author
    ) external onlyAdmin {
        BookData storage bookData = s_ISBNtoBookData[_ISBN];
        bookData.title = _title;
        bookData.year = _year;
        bookData.author = _author;
        bookData.ISBN = getISBN(_title, _year, _author);

        s_bookDatas[bookData.bookIndex] = bookData;
        s_ISBNtoBookData[_ISBN].ISBN = bookData.ISBN;
        s_ISBNtoBookData[bookData.ISBN] = bookData;

        delete s_ISBNtoBookData[_ISBN];
        emit UpdateBook(
            msg.sender,
            bookData.ISBN,
            bookData.title,
            bookData.year,
            bookData.author
        );
    }

    function deleteBook(string calldata _ISBN) external onlyAdmin {
        BookData[] memory bookDatas = s_bookDatas;

        BookData memory bookDataToDelete = s_ISBNtoBookData[_ISBN];
        uint256 indexToDelete = bookDataToDelete.bookIndex;

        uint256 indexToMove = bookDatas.length - 1;
        BookData memory bookDataToMove = bookDatas[indexToMove];

        s_ISBNtoBookData[bookDataToMove.ISBN].bookIndex = indexToDelete;
        s_bookDatas[indexToDelete] = s_ISBNtoBookData[bookDataToMove.ISBN];

        delete s_ISBNtoBookData[_ISBN];
        s_bookDatas.pop();
        s_bookCount -= 1;

        emit DeleteBook(msg.sender, bookDataToDelete.ISBN);
    }

    function getBookCount() public view returns (uint256) {
        return s_bookCount;
    }

    function getISBN(
        string memory _title,
        string memory _year,
        string memory _author
    ) internal view returns (string memory) {
        bytes memory hashData = abi.encodePacked(
            getBookCount(),
            _title,
            _year,
            _author
        );
        return (uint256(keccak256(hashData))).toString();
    }
}

// owner: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// admin1: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// admin2: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// non priviledge: 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

/* 
    Generate random ISBN:
    Dengan menggunakan hash dari kombinasi function bookCount, judul, tahun terbit, dan juga penulis 
    sehingga hasil yang dihasilkan:
        - akan random karena menggunakan hash
        - akan unique karena tidak ada penulis yang menulis judul buku yang sama di tahun terbit yang sama,
          sekalipun kalau ada tidak akan di simpan di dalam sistem dengan bookCount yang sama
*/

// book1: "Ethereum whitepaper","2014","Vitalik Buterin"    | admin1
// book2: "Binance whitepaper","2017","Binance"             | admin1
// book3: "Bitcoin whitepaper","2008","Satoshi Nakamoto"    | admin2

// update book2: "Uniswap whitepaper","2018","Uniswap"      | update book2 -> admin2

/* 
    TestCase:
        - only owner can add admin          | true
        - not owner cannot add admin        | admin cannot add admin, non priviledge cannot add admin
        - cannot add admin if already admin | true

        - not admin cannot add book         | owner cannot, non priviledge cannot
        - only admin can add book           | true

        - owner can get book                | true
        - admin can get book                | true
        - non priviledge can get book       | true

        - not admin cannot update book      | owner cannot, non priviledge cannot
        - only admin can update book        | true

        - not admin cannot delete book      | owner cannot, non priviledge cannot
        - only admin can delete book        | true
*/
