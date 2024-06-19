async function main() {
    // Get the contract factory
    const SilatuEstateInvestmentContract = await ethers.getContractFactory("SilatuEstateInvestmentContract");

    // Deploy the contract
    const contract = await SilatuEstateInvestmentContract.deploy();

    // Wait for the contract to be deployed
    await contract.deployed();

    // Log the address of the deployed contract
    console.log("SilatuEstateInvestmentContract deployed to:", contract.address);
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
