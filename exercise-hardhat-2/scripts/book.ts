import { ethers } from "hardhat";
import { Book } from "../typechain-types";

async function main() {
  const book = await ethers.getContract<Book>("Book");

  const accounts = await ethers.getSigners();
  const owner = accounts[0];
  const admin = accounts[1];

  console.log("Adding admin...");
  const addAdmin = await book.connect(owner).addAdmin(admin);
  await addAdmin.wait();
  console.log("Add admin successfull...\n");

  const adminBookContract = await book.connect(admin);

  console.log("Admin adding book...");
  const addBook = await book
    .connect(admin)
    .addBook("Ethereum whitepaper", "2014", "Vitalik Buterin");
  await addBook.wait();
  console.log("Adding book successfull...");

  const ISBN = (await adminBookContract.s_bookDatas(0)).ISBN;
  const bookData = await adminBookContract.getBook(ISBN);
  console.log("added book data: ", bookData);

  const bookCount = await adminBookContract.getBookCount();
  console.log("book count: ", bookCount);
  console.log("");

  console.log("Updating book...");
  const updateBook = await adminBookContract.updateBook(
    ISBN,
    "Uniswap whitepaper",
    "2018",
    "Uniswap"
  );
  await updateBook.wait();
  console.log("Book updated...");

  const updatedISBN = (await adminBookContract.s_bookDatas(0)).ISBN;
  const updateBookData = await adminBookContract.getBook(updatedISBN);
  console.log("updated book result book data: ", updateBookData);
  console.log("");

  const getBook = await adminBookContract.getBook(updatedISBN);
  console.log("get updated book: ", getBook);
  console.log("");

  console.log("Deleting book....");
  const deleteBook = await adminBookContract.deleteBook(updatedISBN);
  await deleteBook.wait();
  console.log("Book deleted...");

  const deletedBookCount = await adminBookContract.getBookCount();
  console.log("book count: ", deletedBookCount);
}

main().catch((error) => {
  console.log("error = ", error);
  process.exitCode = 1;
});
