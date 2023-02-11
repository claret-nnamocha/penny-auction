import { ethers } from 'hardhat'

async function main() {
  const PennyAuction = await ethers.getContractFactory('PennyAuction')
  const pennyAuction = await PennyAuction.deploy()

  await pennyAuction.deployed()

  console.log(`PennyAuction deployed to ${pennyAuction.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
