import { Abi, Address, parseEther } from 'viem';
import { machineAbi } from './abis/mintAbi';
import { erc20Abi } from './abis/erc20Abi';

const LOCALHOST = 'http://localhost:3000';
const DOMAIN_URL = 'https://themagicmachine.vercel.app';
export const URL: string = process.env.NODE_ENV === 'development' ? LOCALHOST : DOMAIN_URL;


type ContractData = {
  abi: Abi,
  address: Address
}

// base contracts
export const MACHINE: ContractData = {
  abi: machineAbi,
  address: '0xB07b0Cf8305D6b40A9d6EfEbA12Ae81C0FfeFed5'
}

export const MACHINE_ZORA: Address = "0xaAb5272670fa89dA30114A8FbE22324FaC96bEb4";

export const DEGEN: ContractData = {
  abi: erc20Abi,
  address: '0x4ed4E862860beD51a9570b96d89aF5E1B0Efefed' //'0x012e2725400D3480D9Bc6E71cB36e07CE094ef62'
}

export const TN100X: ContractData = {
  abi: erc20Abi,
  address: '0x5B5dee44552546ECEA05EDeA01DCD7Be7aa6144A' //'0x012e2725400D3480D9Bc6E71cB36e07CE094ef62'
}

// HIGHER ?!

export const ENJOY: ContractData = {
  abi: erc20Abi,
  address: '0xa6B280B42CB0b7c4a4F789eC6cCC3a7609A1Bc39' //'0xc248c157Ab73C1d71927626FaB0F01Ce58811ddd'
}

export const IMAGINE: ContractData = {
  abi: erc20Abi,
  address: '0x078540eecc8b6d89949c9c7d5e8e91eab64f6696' //'0xc248c157Ab73C1d71927626FaB0F01Ce58811ddd'
}

export const PRICE = parseEther('0.001').toString();
export const DEGEN_PRICE = parseEther('420');
export const TN100X_PRICE = parseEther('4200');
export const ENJOY_PRICE = parseEther('33333');
export const IMAGINE_PRICE = parseEther('1111');
export const MULTIAMOUNT = BigInt(3);
export const MULTIPRICE = (parseEther('0.000777') * MULTIAMOUNT * BigInt(90) / BigInt(100)).toString();

