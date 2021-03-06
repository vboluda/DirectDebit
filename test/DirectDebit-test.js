const { expect, assert } = require("chai");

describe("DirectDebit", function() {
  it("test owner", async function() {
    const DirectDebit = await ethers.getContractFactory("DirectDebit");
    const directdebit = await DirectDebit.deploy();
    const [owner, addr1] = await ethers.getSigners()
    
    await directdebit.deployed();
    //console.log("LOG - GETOWNER "+await directdebit.getOwner());
    //console.log("LOG - OWNER "+(await owner.getAddress()))
    expect(await directdebit.getOwner()).equal(await owner.getAddress());
  });

  it("test balance", async function() {
    const [owner] = await ethers.getSigners();

    const DirectDebit = await ethers.getContractFactory("DirectDebit");
    const directdebit = await DirectDebit.deploy();
    await directdebit.deployed();

    //console.log("LOG - DEPLOYED ");
    await owner.sendTransaction({
      to: directdebit.address,
      value: 1000
    });

    //console.log("LOG - TX SENT");

    let balance=(await directdebit.getBalance());
    //console.log("LOG - CONTRACT BALANCE "+balance);
    expect(""+balance).equals("1000");
  });

  it("test allow&deny", async function() {
    const [owner,address1,address2] = await ethers.getSigners();

    const DirectDebit = await ethers.getContractFactory("DirectDebit");
    const directdebit = await DirectDebit.deploy();
    await directdebit.deployed();

    //console.log("LOG - DEPLOYED ");
    let allowedRecipient=await directdebit.getAllowed(await address1.getAddress());
    //console.log("LOG - allowed "+JSON.stringify(allowedRecipient));
    assert.isNotTrue(allowedRecipient[0]);
    await directdebit.allow(await address1.getAddress(),10000);
    allowedRecipient=await directdebit.getAllowed(await address1.getAddress());
    //console.log("LOG - allowed "+JSON.stringify(allowedRecipient));
    assert.isTrue(allowedRecipient[0]);
    expect(""+allowedRecipient[1]).equals("10000");
    allowedRecipient=await directdebit.getAllowed(await address2.getAddress());
    //console.log("LOG - allowed "+JSON.stringify(allowedRecipient));
    assert.isNotTrue(allowedRecipient[0]);
  });

});
