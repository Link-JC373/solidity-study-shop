/* eslint-disable @typescript-eslint/no-var-requires */
// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'
import getWeb3 from './getWeb3';
const ecommerce_store_artifacts = require('../contracts/EcommerceStore.json');

const EcommerceStore = contract(ecommerce_store_artifacts);

const ipfsAPI = require('ipfs-api');
const ethUtil = require('ethereumjs-util');

const ipfs = ipfsAPI({host: 'localhost', port: '5001', protocol: 'http'});
