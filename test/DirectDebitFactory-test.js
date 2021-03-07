const { expect, assert } = require("chai");

//THIS TESTS ARE NOT ENOUGHT. SHOULD BE MUCH MORE DETAILED 

describe("DirectDebitFactory", function() {
  it("test owner", async function() {
    const DirectDebitFactory = await ethers.getContractFactory("DirectDebitFactory");
    const instance = await DirectDebitFactory.deploy();
    const [owner, addr1] = await ethers.getSigners()
    
    await instance.deployed();
    await instance.createNewDirectDebitContract();
    console.log("LOG - GETOWNER "+await instance.getOwner());
    console.log("LOG - OWNER "+(await owner.getAddress()))
    expect(await instance.getOwner()).equal(await owner.getAddress());
  });

  it("test balance", async function() {
    const [owner] = await ethers.getSigners();

    const DirectDebit = await ethers.getContractFactory("DirectDebitFactory");
    const instance = await DirectDebit.deploy();
    await instance.deployed();
    await instance.createNewDirectDebitContract();

    //console.log("LOG - DEPLOYED ");
    await owner.sendTransaction({
      to: (await instance.getContractAddress()),
      value: 1000
    });

    //console.log("LOG - TX SENT");

    let balance=(await instance.getBalance());
    //console.log("LOG - CONTRACT BALANCE "+balance);
    expect(""+balance).equals("1000");
    //await directdebit.returnFunds(2000);
    //expect(""+balance).equals("1000");
    await instance.returnFunds(500);
    balance=(await instance.getBalance());
    expect(""+balance).equals("500");
  });

  it("test allow&deny", async function() {
    const [owner,address1,address2] = await ethers.getSigners();

    const DirectDebit = await ethers.getContractFactory("DirectDebitFactory");
    const instance = await DirectDebit.deploy();
    await instance.deployed();
    await instance.createNewDirectDebitContract();

    //console.log("LOG - DEPLOYED ");
    let allowedRecipient=await instance.getAllowed(await address1.getAddress());
    //console.log("LOG - allowed "+JSON.stringify(allowedRecipient));
    assert.isNotTrue(allowedRecipient[0]);
    await instance.allow(await address1.getAddress(),10000);
    allowedRecipient=await instance.getAllowed(await address1.getAddress());
    //console.log("LOG - allowed "+JSON.stringify(allowedRecipient));
    assert.isTrue(allowedRecipient[0]);
    expect(""+allowedRecipient[1]).equals("10000");
    allowedRecipient=await instance.getAllowed(await address2.getAddress());
    //console.log("LOG - allowed "+JSON.stringify(allowedRecipient));
    assert.isNotTrue(allowedRecipient[0]);
  });

  it("test process orders", async function() {
    const [owner,address1] = await ethers.getSigners();

    const DirectDebit = await ethers.getContractFactory("DirectDebitFactory");
    const instance = await DirectDebit.deploy();
    await instance.deployed();
    await instance.createNewDirectDebitContract();

    console.log("LOG - DEPLOYED ");
    let _address1=await address1.getAddress();
    let order=await instance.getOrder(_address1,1);
    //console.log("LOG - GetOrder "+JSON.stringify(order));
    await instance.allow(_address1,2000);
    await instance.addOrder(
      _address1,
      1,
      "0x9944615dfc9c3a705f4363e6659196a61eaa140ab72922df3ac1f7814f050164",
      1000
      );
    order=await instance.getOrder(_address1,1);
    //console.log("LOG - GetOrder "+JSON.stringify(order));
    expect(order[0]).equals("0x9944615dfc9c3a705f4363e6659196a61eaa140ab72922df3ac1f7814f050164");

    await owner.sendTransaction({
      to: (await instance.getContractAddress()),
      value: 3000
    });

    await instance.orderAprobal(_address1,1);

    balance=(await instance.getBalance());
    //console.log("LOG - Balance "+balance);
    expect(""+balance).equals("2000");
  });
});