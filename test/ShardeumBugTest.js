const Web3 = require('web3')
const ethers = require("ethers")

const rpcURL = "https://liberty20.shardeum.org/"
const web3 = new Web3(rpcURL)

const provider = new ethers.providers.JsonRpcProvider(rpcURL)
const signer = new ethers.Wallet(Buffer.from(process.env.devTestnetPrivateKey, 'hex'), provider);
console.log("User wallet address: " + signer.address)

const contractAddress_JS = '0x0eeb678A8D0Fe8C82e9B7D5782A9f4074c34BD99'
const contractABI_JS = [{"inputs":[{"internalType":"address","name":"_token","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"tokenObject","outputs":[{"internalType":"contractERC20TokenContract","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"transferBothTests","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"transferFromTest","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"transferTest","outputs":[],"stateMutability":"nonpayable","type":"function"}]

const contractDefined_JS = new web3.eth.Contract(contractABI_JS, contractAddress_JS)

const timeMilliSec = 1000;

function timeout(ms) {
	return new Promise(resolve => setTimeout(resolve,ms));
}

createAndSendTx();

async function createAndSendTx() {

    const chainIdConnected = await web3.eth.getChainId();
    console.log("chainIdConnected: "+ chainIdConnected)

    const addressWSHM = await contractDefined_JS.methods.tokenObject().call()
		const abiWSHM = [{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"subtractedValue","type":"uint256"}],"name":"decreaseAllowance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"addedValue","type":"uint256"}],"name":"increaseAllowance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]
    const deployedWSHM = new web3.eth.Contract(abiWSHM, addressWSHM)

		console.log("addressWSHM: "+ addressWSHM)

		const signerBalanceWSHM = await deployedWSHM.methods.balanceOf(signer.address).call()
		console.log("signerBalanceWSHM: "+ signerBalanceWSHM)

		const allowanceSignerMulticall = await deployedWSHM.methods.allowance(signer.address,contractAddress_JS).call()
		console.log("allowanceSignerMulticall: "+ allowanceSignerMulticall)

    const codeHash = await provider.getCode(addressWSHM)
    console.log("addressWSHM codeHash: " + codeHash)

    let txCount = await provider.getTransactionCount(signer.address);

    // const approveOneEtherWSHM = signer.sendTransaction({
    //     chainId: chainIdConnected,
    //     to: addressWSHM,
    //     nonce:    web3.utils.toHex(txCount),
    //     gasLimit: web3.utils.toHex(2100000), // Raise the gas limit to a much higher amount
    //     gasPrice: web3.utils.toHex(web3.utils.toWei('30', 'gwei')),
    //     data: deployedWSHM.methods.approve(contractAddress_JS,"2000000000000000000").encodeABI(),
		//
    // });
		//
    // console.log("WAIT FOR TX RECEIPT: ")
    // await approveOneEtherWSHM
    // console.log("TX RECEIPT: ")
    // console.log(approveOneEtherWSHM)
		// console.log("WAIT 30 SECONDS, THEN TRY TO APPROVE WSHM BEFORE WITHDRAW! ")
		// await timeout(30*timeMilliSec)

		// MAKE SURE YOU APPROVE WSHM BEFORE YOU TRY TO WITHDRAW TO CALL "transferFrom()"!
		txCount = await provider.getTransactionCount(signer.address);

    // const depositTwoEtherSHM = signer.sendTransaction({
    //     chainId: chainIdConnected,
    //     to: contractAddress_JS,
    //     nonce:    web3.utils.toHex(txCount),
    //     gasLimit: web3.utils.toHex(2100000), // Raise the gas limit to a much higher amount
    //     gasPrice: web3.utils.toHex(web3.utils.toWei('30', 'gwei')),
    //     data: contractDefined_JS.methods.transferFromTest().encodeABI(),
    //     type: 1,
    //     accessList: [
    //       {
    //         address: addressWSHM, //Contract address we are calling from the "to" contract at some point.
    //         storageKeys: [
    //           codeHash, //Code hash from EXTCODEHASH https://blog.finxter.com/how-to-find-out-if-an-ethereum-address-is-a-contract/
    //         ]
    //       }
    //     ]
		//
    // });
		//
    // console.log("WAIT FOR TX RECEIPT: ")
    // await depositTwoEtherSHM
    // console.log("TX RECEIPT: ")
    // console.log(depositTwoEtherSHM)
		//
		// console.log("WAIT 30 SECONDS, THEN TRY TO WITHDRAW! ")
		// await timeout(30*timeMilliSec)

    txCount = await provider.getTransactionCount(signer.address);

    const withdrawOneEtherSHM = signer.sendTransaction({
        chainId: chainIdConnected,
        to: contractAddress_JS,
        nonce:    web3.utils.toHex(txCount),
        gasLimit: web3.utils.toHex(2100000), // Raise the gas limit to a much higher amount
        gasPrice: web3.utils.toHex(web3.utils.toWei('30', 'gwei')),
        data: contractDefined_JS.methods.transferTest().encodeABI(),
        type: 1,
        accessList: [
          {
            address: addressWSHM, //Contract address we are calling from the "to" contract at some point.
            storageKeys: [
              codeHash, //Code hash from EXTCODEHASH https://blog.finxter.com/how-to-find-out-if-an-ethereum-address-is-a-contract/
            ]
          }
        ]

    });

    console.log("WAIT FOR TX RECEIPT: ")
    await withdrawOneEtherSHM
    console.log("TX RECEIPT: ")
    console.log(withdrawOneEtherSHM)

		console.log("WAIT 30 SECONDS, THEN TRY TO WITHDRAW! ")
		await timeout(30*timeMilliSec)

		txCount = await provider.getTransactionCount(signer.address);

		const testBoth = signer.sendTransaction({
				chainId: chainIdConnected,
				to: contractAddress_JS,
				nonce:    web3.utils.toHex(txCount),
				gasLimit: web3.utils.toHex(2100000), // Raise the gas limit to a much higher amount
				gasPrice: web3.utils.toHex(web3.utils.toWei('30', 'gwei')),
				data: contractDefined_JS.methods.transferBothTests().encodeABI(),
				type: 1,
				accessList: [
					{
						address: addressWSHM, //Contract address we are calling from the "to" contract at some point.
						storageKeys: [
							codeHash, //Code hash from EXTCODEHASH https://blog.finxter.com/how-to-find-out-if-an-ethereum-address-is-a-contract/
						]
					}
				]

		});

		console.log("WAIT FOR TX RECEIPT: ")
		await testBoth
		console.log("TX RECEIPT: ")
		console.log(testBoth)

}
