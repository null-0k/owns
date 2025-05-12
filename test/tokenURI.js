const { expect } = require("chai");
const { ethers } = require("hardhat");
const fs = require("fs");

describe("OwnsToken.tokenURI", function () {
    let owner, user;
    let font, mnemonic, builder, token;

    const WORDS = JSON.parse(
        fs.readFileSync("files/json/mnemonic.json", "utf8")
    ).mnemonic;

    const CAVEAT = JSON.parse(
        fs.readFileSync("files/json/caveat.json", "utf8")
    ).caveat;

    const INTER = JSON.parse(
        fs.readFileSync("files/json/inter.json", "utf8")
    ).inter;

    beforeEach(async function () {
        [owner, user] = await ethers.getSigners();

        // OwnsFont
        const OwnsFont = await ethers.getContractFactory("OwnsFont");
        font = await OwnsFont.deploy(owner.address);
        await font.waitForDeployment();

        for (let i = 0; i < CAVEAT.length; i++) {
            const caveatBytes = ethers.toUtf8Bytes(CAVEAT[i]);
            await font.addLetters(caveatBytes);
        }
        for (let i = 0; i < INTER.length; i++) {
            const interBytes = ethers.toUtf8Bytes(INTER[i]);
            await font.addDigits(interBytes);
        }  

        // Mnemonic
        const Mnemonic = await ethers.getContractFactory("Mnemonic");
        mnemonic = await Mnemonic.deploy(owner.address);
        await mnemonic.waitForDeployment();

        for (let i = 0; i < 2048; i++) {
            const wordBytes = ethers.toUtf8Bytes(WORDS[i]);
            await mnemonic.setWordList(i, wordBytes);
        }

        // Builder
        const OwnsBuilder = await ethers.getContractFactory("OwnsBuilder");
        builder = await OwnsBuilder.deploy(
            font.target ?? font.address,
            mnemonic.target ?? mnemonic.address
        );
        await builder.waitForDeployment();

        // Token
        const OwnsToken = await ethers.getContractFactory("OwnsToken");
        token = await OwnsToken.deploy(
            owner.address,                  // royalty receiver
            1000,                            // 10 ‰ (1000 ‱)
            builder.target ?? builder.address
        );
        // await token.setMaxSupply(100);
        // await token.setPrice(ethers.parseEther("0.01"));
        await token.setMintActive(true);
    });

    it("Should generate all data including metadata encoded in Base64", async function () {
        await token.connect(user).safeMint(1, { value: ethers.parseEther("0.01") });
        const uri = await token.tokenURI(0);
        expect(uri).to.be.a("string").and.not.equal("");
        console.log(uri);

        const path = "output";                     
        if (!fs.existsSync(path)) {
            fs.mkdirSync(path, { recursive: true });  
        }
        fs.writeFileSync(`${path}/owns.bs64.txt`, uri);  
    });

    it("Should output raw svg", async function () {
        await token.connect(user).safeMint(1, { value: ethers.parseEther("0.01") });
        const svg = await token.svg(0);

        const path = "output";                       
        if (!fs.existsSync(path)) {
            fs.mkdirSync(path, { recursive: true });   
        }
        fs.writeFileSync(`${path}/owns.svg`, svg); 
    });
});