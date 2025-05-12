 const { expect } = require("chai");
 const { ethers } = require("hardhat");
 const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
 const mnemonicPhrase = require("../files/json/mnemonic.json");

 /* ------------ 共通フィクスチャ ------------ */
 async function deployFixture() {
     const [owner, alice] = await ethers.getSigners();
     const Fac = await ethers.getContractFactory("Mnemonic");
     const mnemonic = await Fac.deploy();
     await mnemonic.waitForDeployment();
     return { mnemonic, owner, alice };
 }

 /* ---------- lockWordListの挙動 ---------- */
 describe("Mnemonic - word list I/O", function () {
     let mnemonic;   

     /* ---- 2048語を毎回セット ---- */
     before(async () => {          
         ({ mnemonic } = await loadFixture(deployFixture));
         await Promise.all(
             mnemonicPhrase.map((w, i) =>
                 mnemonic.setWordList(i, ethers.toUtf8Bytes(w))
             )
         );
     });

     it("wordList(i)で正しく取得", async function () {
         for (let i = 0; i < mnemonicPhrase.length; ++i) {
             expect(await mnemonic.wordList(i)).to.equal(mnemonicPhrase[i]);
         }
     });

      it("indexOfWordList(word)が正しいインデックスを返す", async function () {
          for (let i = 0; i < mnemonicPhrase.length; ++i) {
              expect(await mnemonic.indexOfWordList(mnemonicPhrase[i])).to.equal(i);
          }
      });

      it("ニーモニックの取得", async function () {
          const seed = "0x0000000000000000000000000000000000000000000000000000000000000000";
          const hash = ethers.keccak256(seed);   
          const words = await mnemonic.generateMnemonic(256, hash);
          console.log(hash)
          for (const w of words) {
              console.log(w);
          }
      });
 });

 /* ---------- lockWordList の挙動 ---------- */
  describe("Mnemonic - lockWordList()", function () {
      it("オーナーはロックでき,イベントが出る", async function () {
          const { mnemonic, owner } = await loadFixture(deployFixture);

          await expect(mnemonic.connect(owner).lockWordList())
              .to.emit(mnemonic, "SetWordListLocked")
              .withArgs();

          expect(await mnemonic.isSetWordListLocked()).to.be.true;
      });

      it("非オーナーはロックできない", async function () {
          const { mnemonic, alice } = await loadFixture(deployFixture);

          await expect(mnemonic.connect(alice).lockWordList())
              .to.be.revertedWithCustomError(mnemonic, "OwnableUnauthorizedAccount");
      });

      it("二重ロックはできない", async function () {
          const { mnemonic, owner } = await loadFixture(deployFixture);

          await mnemonic.lockWordList();
          await expect(mnemonic.lockWordList())
              .to.be.revertedWith("BIP39 is locked");
      });

      it("ロック後はsetWordListが使えない", async function () {
          const { mnemonic } = await loadFixture(deployFixture);

          await mnemonic.lockWordList();
          await expect(
              mnemonic.setWordList(0, ethers.toUtf8Bytes("abandon"))
          ).to.be.revertedWith("BIP39 is locked");
      });
  });


