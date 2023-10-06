import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { Book } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";

describe("Book", function () {
  let book: Book;
  let owner: HardhatEthersSigner;
  let admin: HardhatEthersSigner;
  let nonPriviledge: HardhatEthersSigner;

  beforeEach(async () => {
    const accounts = await ethers.getSigners();
    owner = accounts[0];
    admin = accounts[1];
    nonPriviledge = accounts[2];

    book = await (await ethers.getContractFactory("Book"))
      .connect(owner)
      .deploy();

    const addAdmin = await book.connect(owner).addAdmin(admin);
    await addAdmin.wait();
  });

  it("Check admin address is correct", async () => {
    const expectedAdmin = await book.s_admins(0);
    expect(expectedAdmin).to.be.equal(admin.address);
  });

  describe("add book", () => {
    it("check owner cannot add book", async () => {
      const ownerAddBook = await book.connect(owner);

      await expect(
        ownerAddBook.addBook("Ethereum whitepaper", "2014", "Vitalik Buterin")
      ).to.be.revertedWithCustomError(ownerAddBook, "Book__NotAdmin");
    });

    it("check non priviledge cannot add book", async () => {
      const nonPriviledgeAddBook = await book.connect(nonPriviledge);

      await expect(
        nonPriviledgeAddBook.addBook(
          "Ethereum whitepaper",
          "2014",
          "Vitalik Buterin"
        )
      ).to.be.revertedWithCustomError(nonPriviledgeAddBook, "Book__NotAdmin");
    });

    it("check admin can add book", async () => {
      const adminAddBook = await book.connect(admin);

      const addBook = await adminAddBook.addBook(
        "Ethereum whitepaper",
        "2014",
        "Vitalik Buterin"
      );
      await addBook.wait();

      const bookData = await adminAddBook.s_bookDatas(0);
      expect("Ethereum whitepaper").to.be.equal(bookData.title);
      expect("2014").to.be.equal(bookData.year);
      expect("Vitalik Buterin").to.be.equal(bookData.author);
    });
  });

  describe("update book", () => {
    let ISBN: string;

    beforeEach(async () => {
      const adminAddBook = await book.connect(admin);

      const addBook = await adminAddBook.addBook(
        "Ethereum whitepaper",
        "2014",
        "Vitalik Buterin"
      );
      await addBook.wait();

      ISBN = (await adminAddBook.s_bookDatas(0)).ISBN;
    });

    it("check owner cannot update book", async () => {
      const ownerBook = await book.connect(owner);

      await expect(
        ownerBook.updateBook(ISBN, "Uniswap whitepaper", "2018", "Uniswap")
      ).to.be.revertedWithCustomError(ownerBook, "Book__NotAdmin");
    });

    it("check non priviledge cannot update book", async () => {
      const nonPriviledgeBook = await book.connect(nonPriviledge);

      await expect(
        nonPriviledgeBook.updateBook(
          ISBN,
          "Uniswap whitepaper",
          "2018",
          "Uniswap"
        )
      ).to.be.revertedWithCustomError(nonPriviledgeBook, "Book__NotAdmin");
    });

    it("check admin can update book", async () => {
      const adminBook = book.connect(admin);

      const updateBook = await adminBook.updateBook(
        ISBN,
        "Uniswap whitepaper",
        "2018",
        "Uniswap"
      );
      await updateBook.wait();

      const bookData = await adminBook.s_bookDatas(0);
      expect("Uniswap whitepaper").to.be.equal(bookData.title);
      expect("2018").to.be.equal(bookData.year);
      expect("Uniswap").to.be.equal(bookData.author);
    });
  });

  describe("get book", () => {
    let ISBN: string;

    beforeEach(async () => {
      const adminAddBook = await book.connect(admin);

      const addBook = await adminAddBook.addBook(
        "Ethereum whitepaper",
        "2014",
        "Vitalik Buterin"
      );
      await addBook.wait();

      ISBN = (await adminAddBook.s_bookDatas(0)).ISBN;
    });

    it("check owner can get book", async () => {
      const ownerBook = await book.connect(owner);

      const getBook = await ownerBook.getBook(ISBN);

      expect("Ethereum whitepaper").to.be.equal(getBook.title);
      expect("2014").to.be.equal(getBook.year);
      expect("Vitalik Buterin").to.be.equal(getBook.author);
    });

    it("check non priviledge can get book", async () => {
      const nonPriviledgeBook = await book.connect(nonPriviledge);

      const getBook = await nonPriviledgeBook.getBook(ISBN);

      expect("Ethereum whitepaper").to.be.equal(getBook.title);
      expect("2014").to.be.equal(getBook.year);
      expect("Vitalik Buterin").to.be.equal(getBook.author);
    });

    it("check admin can get book", async () => {
      const adminBook = await book.connect(admin);

      const getBook = await adminBook.getBook(ISBN);

      expect("Ethereum whitepaper").to.be.equal(getBook.title);
      expect("2014").to.be.equal(getBook.year);
      expect("Vitalik Buterin").to.be.equal(getBook.author);
    });
  });

  describe("delete book", () => {
    let ISBN: string;

    beforeEach(async () => {
      const adminAddBook = await book.connect(admin);

      const addBook = await adminAddBook.addBook(
        "Ethereum whitepaper",
        "2014",
        "Vitalik Buterin"
      );
      await addBook.wait();

      ISBN = (await adminAddBook.s_bookDatas(0)).ISBN;
    });

    it("check owner cannot delete book", async () => {
      const ownerBook = book.connect(owner);

      await expect(ownerBook.deleteBook(ISBN)).to.be.revertedWithCustomError(
        ownerBook,
        "Book__NotAdmin"
      );
    });

    it("check non priviledge cannot delete book", async () => {
      const nonPriviledgeBook = book.connect(nonPriviledge);

      await expect(
        nonPriviledgeBook.deleteBook(ISBN)
      ).to.be.revertedWithCustomError(nonPriviledgeBook, "Book__NotAdmin");
    });

    it("check admin can delete book", async () => {
      const adminBook = book.connect(admin);

      const bookCount = await adminBook.getBookCount();
      expect(bookCount).to.be.equal(1);

      const deleteBook = await adminBook.deleteBook(ISBN);
      await deleteBook.wait();

      const deletedBookCount = await adminBook.getBookCount();
      expect(deletedBookCount).to.be.equal(0);
    });
  });
});
