import * as web3 from '@solana/web3.js';
import * as spl from '@solana/spl-token';
import { getRpc, newConnection } from "./lib/solana";
import axios from "axios";
import { WalletModel } from "./types";
import base58 from "bs58";
import { HeliusManager } from "./HeliusManager";
import { bs58 } from "@coral-xyz/anchor/dist/cjs/utils/bytes";
import { TransactionMessage } from "@solana/web3.js";
import { Helpers } from "../helpers/Helpers";
import { EnrichedTransaction, Helius, Interface } from "helius-sdk";
import BN from "bn.js";
import { kSolAddress } from './Constants';

export interface CreateTransactionResponse {
    tx: web3.Transaction,
    blockhash: web3.BlockhashWithExpiryBlockHeight,
}

export interface TokenBalance {
    amount: BN;
    uiAmount: number;
    decimals?: number;
    ataPubKey?: web3.PublicKey;
}

export interface LPToken {
    lpMint: string,
    amount: BN,
    decimals: number,
    supply: BN,
}

export interface Asset {
    address: string;
    amount: number;
    uiAmount: number;
    decimals: number;

    symbol: string;
    name?: string;
    description?: string;
    logo?: string;
    supply?: number;

    priceInfo?: {
        pricePerToken: number;
        totalPrice: number;
    };

    // mintAuthority?: string;
    // freezeAuthority?: string;
    
    // tokenPrice: number;
    // tokenPriceChange: number;
    // tokenMarketCap: number;
    // tokenVolume: number;
    // tokenLiquidity: number;
    // tokenNft: string;
}

export class SolanaManager {

    static async isBlockhashValid(blockhash: string) : Promise<boolean | undefined> {
        const { data } = await axios.post(getRpc().http, {
            "id": 45,
            "jsonrpc": "2.0",
            "method": "isBlockhashValid",
            "params": [
                blockhash,
                {
                    "commitment": "confirmed"
                }
            ]
        });

        const value = data?.result?.value;

        return (value==true || value==false) ? value : undefined;
    }

    static createWallet(): WalletModel {
        const keyPair = web3.Keypair.generate();

        return {
            publicKey: keyPair.publicKey.toString(),
            privateKey: base58.encode(Array.from(keyPair.secretKey)),
        }
    }

    static async isTransactionContainSigner(transaction: web3.Transaction, signerAddress: string, hasToBeSigned: boolean = true): Promise<boolean> {
        for (const signature of transaction.signatures) {
            if (signature.publicKey.toBase58() == signerAddress){
                if (!hasToBeSigned) { return true; }
                else if (hasToBeSigned && signature.signature){ return true; }
            }
        }

        return false;
    }
    
    static async createSplTransferInstructions(web3Conn: web3.Connection, splTokenMintPublicKey: web3.PublicKey, amount: number, decimals: number, fromPublicKey: web3.PublicKey, toPublicKey: web3.PublicKey, feePayerPublicKey: web3.PublicKey): Promise<web3.TransactionInstruction[]>{
        const fromTokenAddress = await spl.getAssociatedTokenAddress(splTokenMintPublicKey, fromPublicKey);
        const toTokenAddress = await spl.getAssociatedTokenAddress(splTokenMintPublicKey, toPublicKey);
        const instructions: web3.TransactionInstruction[] = [];

        const instruction1 = await this.getInstrucionToCreateTokenAccount(web3Conn, splTokenMintPublicKey, fromTokenAddress, fromPublicKey, feePayerPublicKey);
        if (instruction1 != undefined){
            instructions.push(instruction1);
        }

        const instruction2 = await this.getInstrucionToCreateTokenAccount(web3Conn, splTokenMintPublicKey, toTokenAddress, toPublicKey, feePayerPublicKey);
        if (instruction2 != undefined){
            instructions.push(instruction2);
        }

        instructions.push(
            spl.createTransferInstruction(
                fromTokenAddress, 
                toTokenAddress, 
                fromPublicKey, 
                Math.floor(amount * 10**decimals)
            )
        );
    
        return instructions;
    }  

    static async getAtaAddress(walletAddress: web3.PublicKey, mint: web3.PublicKey): Promise<web3.PublicKey> {
        const publicKey = await spl.getAssociatedTokenAddress(mint, walletAddress);
        return publicKey;
    }

    static async createSplAccountInstruction(mint: web3.PublicKey, walletPublicKey: web3.PublicKey, feePayerPublicKey: web3.PublicKey, tokenAddress?: web3.PublicKey): Promise<web3.TransactionInstruction>{
        if (!tokenAddress){
            tokenAddress = await spl.getAssociatedTokenAddress(mint, walletPublicKey);
        }

        console.log(process.env.SERVER_NAME, 'createSplAccountInstruction', 'tokenAddress', tokenAddress.toBase58());
        return spl.createAssociatedTokenAccountInstruction(
            feePayerPublicKey,
            tokenAddress,
            walletPublicKey,
            mint,
            spl.TOKEN_PROGRAM_ID,
            spl.ASSOCIATED_TOKEN_PROGRAM_ID
        );    
    }  

    static async createSolTransferInstruction(fromPublicKey: web3.PublicKey, toPublicKey: web3.PublicKey, lamports: number): Promise<web3.TransactionInstruction> {
        return web3.SystemProgram.transfer({
            fromPubkey: fromPublicKey,
            toPubkey: toPublicKey,
            lamports: lamports,
        });
    }

    static async getInstrucionToCreateTokenAccount(
        web3Conn: web3.Connection, 
        tokenMintPublicKey: web3.PublicKey, 
        tokenAccountAddressPublicKey: web3.PublicKey, 
        ownerAddressPublicKey: web3.PublicKey, 
        feePayerPublicKey: web3.PublicKey
    ): Promise<web3.TransactionInstruction | undefined> {

        try {
            const account = await spl.getAccount(
                web3Conn, 
                tokenAccountAddressPublicKey, 
                undefined, 
                spl.TOKEN_PROGRAM_ID
            );
            console.log('MIKE BONK ACCOUNT EXISTS', account);
        } catch (error: unknown) {
            console.log('MIKE BONK ACCOUNT NOT EXISTS');

            if (error instanceof spl.TokenAccountNotFoundError || error instanceof spl.TokenInvalidAccountOwnerError) {
                return spl.createAssociatedTokenAccountInstruction(
                    feePayerPublicKey,
                    tokenAccountAddressPublicKey,
                    ownerAddressPublicKey,
                    tokenMintPublicKey,
                    spl.TOKEN_PROGRAM_ID,
                    spl.ASSOCIATED_TOKEN_PROGRAM_ID
                );
            } else {
                throw error;
            }
        }
    }

    static async getWalletSolBalance(web3Conn: web3.Connection, walletAddress?: string): Promise<TokenBalance | undefined>{
        if (!walletAddress) return undefined;

        try {
            const mainWalletPublicKey = new web3.PublicKey(walletAddress);
            const balance = await web3Conn.getBalance(mainWalletPublicKey);
            return {amount: new BN(balance), uiAmount: Math.round(1000 * balance / web3.LAMPORTS_PER_SOL) / 1000, decimals: 9};
        }
        catch (err){
            console.error('getWalletSolBalance', err);
        }

        return undefined;
    }

    static async getWalletsSolBalances(web3Conn: web3.Connection, walletAddresses: string[]): Promise<(TokenBalance & {publicKey: string})[]>{
        const publicKeys = walletAddresses.map(address => new web3.PublicKey(address));
        const accounts = await web3Conn.getMultipleAccountsInfo(publicKeys);

        const balances: (TokenBalance & {publicKey: string})[] = [];
        let index = 0;
        for (const account of accounts) {
            const publicKey = walletAddresses[index];

            if (account) {
                balances.push({amount: new BN(account.lamports), uiAmount: account.lamports / web3.LAMPORTS_PER_SOL, decimals: 9, publicKey});
            }
            else {
                balances.push({amount: new BN(0), uiAmount: 0, decimals: 9, publicKey});
            }

            index++;
        }

        return balances;
    }

    static async getWalletTokenBalance(web3Conn: web3.Connection, walletAddress: string, tokenAddress: string): Promise<TokenBalance>{
        try {
            // console.log(process.env.SERVER_NAME, 'getWalletTokenBalance', 'walletAddress', walletAddress, 'tokenAddress', tokenAddress);
            const mainWalletPublicKey = new web3.PublicKey(walletAddress);
            const tokenPublicKey = new web3.PublicKey(tokenAddress);
            const tmp = await web3Conn.getParsedTokenAccountsByOwner(mainWalletPublicKey, {mint: tokenPublicKey});
            // console.log(process.env.SERVER_NAME, 'getWalletTokenBalance', 'tmp', JSON.stringify(tmp));

            return {
                amount: new BN(tmp.value[0].account.data.parsed.info.tokenAmount.amount), 
                uiAmount: +(tmp.value[0].account.data.parsed.info.tokenAmount.uiAmount),
                decimals: tmp.value[0].account.data.parsed.info.tokenAmount.decimals,
                ataPubKey: tmp.value[0].pubkey
            }
        }
        catch (err){
            // console.error('getWalletTokenBalance', err);
        }

        return {amount: new BN(0), uiAmount: 0};
    }

    static isValidPublicKey(publicKey: string): boolean {
        console.log(`isValidPublicKey: "${publicKey}"`);
        try {
            const pk = new web3.PublicKey(publicKey);
            return true; // web3.PublicKey.isOnCurve(pk);
        }
        catch (err){
            // console.error('isValidPublicKey', err);
        }

        return false;
    }

    static async getParsedTransaction(signature: string, tries: number = 3): Promise<web3.ParsedTransactionWithMeta | undefined>{
        const txs = await this.getParsedTransactions([signature], tries);
        return txs.length > 0 ? txs[0] : undefined;
    }

    static async getParsedTransactions(signatures: string[], tries: number = 3): Promise<web3.ParsedTransactionWithMeta[]>{
        const connection = newConnection();
        if (signatures.length == 0) return [];

        let txs: (web3.ParsedTransactionWithMeta | null)[] = [];

        while (txs.length==0 && tries > 0){
            try {
                txs = await connection.getParsedTransactions(signatures, {commitment: 'confirmed', maxSupportedTransactionVersion: 0});
            }
            catch (err){}
            tries--;

            if (!txs){
                await Helpers.sleep(1);
            }
        }

        return txs.filter(tx => tx != null && !tx.meta?.err) as web3.ParsedTransactionWithMeta[];
    }    

    static async getTokenAccountBalance(web3Conn: web3.Connection, tokenAccount: web3.PublicKey): Promise<web3.TokenAmount | undefined>{
        try {
            const balance = await web3Conn.getTokenAccountBalance(tokenAccount, 'confirmed');
            return balance.value;
        }
        catch (err){
            console.error('getTokenAccountBalance', err);
        }

        return undefined;
    }

    static async getAddressLookupTableAccounts(connection: web3.Connection, keys: string[]) {
        const addressLookupTableAccountInfos = await connection.getMultipleAccountsInfo(
            keys.map((key) => new web3.PublicKey(key))
        );
      
        const results = addressLookupTableAccountInfos.reduce((acc: web3.AddressLookupTableAccount[], accountInfo, index) => {
            const addressLookupTableAddress = keys[index];
            if (accountInfo) {
                const addressLookupTableAccount = new web3.AddressLookupTableAccount({
                    key: new web3.PublicKey(addressLookupTableAddress),
                    state: web3.AddressLookupTableAccount.deserialize(accountInfo.data),
                });
                acc.push(addressLookupTableAccount);
            }
            return acc;
        }, []);

        return results;
    };

    static async getAssetsByOwner(walletAddress: string): Promise<{ sol: Asset, assets: Asset[] }> {
        const heliusData = await HeliusManager.getAssetsByOwner(walletAddress, {
            showNativeBalance: true,
            // showFungible: true,
            showSystemMetadata: true,
            // showGrandTotal: false,
            // showClosedAccounts: false,
            // showZeroBalance: false,
            // showCollectionMetadata: false,
            // showUnverifiedCollections: false,
            // showRawData: false,
        });
        const heliusAssets = heliusData.items;
        const nativeBalance = heliusData.nativeBalance;

        const assets: Asset[] = [];

        const sol: Asset = {
            address: kSolAddress,
            amount: nativeBalance?.lamports || 0,
            uiAmount: (nativeBalance?.lamports || 0) / web3.LAMPORTS_PER_SOL,
            decimals: 9,
            symbol: 'SOL',
            name: 'Solana',
            logo: 'https://light.dangervalley.com/static/sol.png',
            priceInfo: { 
                pricePerToken: nativeBalance?.price_per_sol || 0, 
                totalPrice: nativeBalance?.total_price || 0,
            },
        };

        for (const heliusAsset of heliusAssets) {
            if (heliusAsset.interface != Interface.FUNGIBLE_TOKEN && heliusAsset.interface != Interface.FUNGIBLE_ASSET) { continue; }
            if (!heliusAsset.token_info || !heliusAsset.token_info?.symbol) { continue; }
            if (heliusAsset.compression?.compressed) { continue; }

            const decimals = heliusAsset.token_info?.decimals || 0;
            const amount = heliusAsset.token_info?.balance || 0;
            const uiAmount = amount / 10**decimals;
            const logo = heliusAsset.content?.files?.find(file => file.mime == 'image/png' || file.mime == 'image/jpg' || file.mime == 'image/jpeg')?.uri;
            const symbol = heliusAsset.token_info.symbol.trim();
            const name = heliusAsset.content?.metadata?.name ? heliusAsset.content?.metadata?.name.trim() : symbol;

            const pricePerToken = heliusAsset.token_info?.price_info?.price_per_token || 0;
            const totalPrice = heliusAsset.token_info?.price_info?.total_price || 0;

            const asset: Asset = {
                address: heliusAsset.id,
                amount: amount,
                uiAmount: uiAmount,
                decimals: decimals,
                symbol: symbol,
                name: name,
                description: heliusAsset.content?.metadata?.description,
                logo: logo,
                supply: (heliusAsset.token_info?.supply || 0) / 10**decimals,
                priceInfo: heliusAsset.token_info?.price_info ? { pricePerToken, totalPrice } : undefined,
                // mintAuthority: heliusAsset.token_info?.mint_authority,
                // freezeAuthority: heliusAsset.freezeAuthority,
            };

            assets.push(asset);
        }

        for (const asset of assets) {
            if (asset.priceInfo){
                asset.priceInfo.totalPrice = Math.round(1000000 * asset.priceInfo.totalPrice) / 1000000;
            }
        }

        // sort by priceInfo.totalPrice
        assets.sort((a, b) => (b.priceInfo?.totalPrice || 0) - (a.priceInfo?.totalPrice || 0));

        return { sol, assets };
    }

    static createBurnSplAccountInstruction(tokenAta: web3.PublicKey, destination: web3.PublicKey, authority: web3.PublicKey): web3.TransactionInstruction {
        return spl.createCloseAccountInstruction(
            tokenAta,
            destination,
            authority,
        );    
    }  

    static async getTokenSupply(connection: web3.Connection, mint: string): Promise<web3.TokenAmount | undefined> {
        try {
            const mintPublicKey = new web3.PublicKey(mint);
            const supplyInfo = await connection.getTokenSupply(mintPublicKey);
            console.log('supplyInfo:', supplyInfo);
            return supplyInfo?.value;
        }
        catch (err){
            console.error('getTokenSupply', err);
        }

        return undefined;
    }

    static async getTokenMint(mint: string): Promise<spl.Mint | undefined> {
        try {
            const connection = newConnection();
            const mintPublicKey = new web3.PublicKey(mint);
            const mintInfo = await spl.getMint(connection, mintPublicKey);
            return mintInfo;    
        }
        catch (err){
            console.error('getTokenMint', 'err:', err);
        }
        return undefined;
    }

    static async getFreezeAuthorityRevoked(mint: string): Promise<boolean> {
        const mintInfo = await this.getTokenMint(mint);
        if (mintInfo && mintInfo.freezeAuthority == null) {
            return true;
        }
        return false;
    }

    static async getLatestTransactions(walletAddress: string, limit: number = 10): Promise<EnrichedTransaction[]> {
        const connection = newConnection();
        const publicKey = new web3.PublicKey(walletAddress);
        const signatures = await connection.getSignaturesForAddress(publicKey, { limit: limit });

        const signs = signatures.map((signature) => {
            return signature.signature;
        });

        const txs = await HeliusManager.getTransactions(signs);
        return txs;
    }

    // static async getWalletTokensBalances(walletAddress: string): Promise<{mint: string, symbol?: string, name?: string, balance: TokenBalance}[]>{
    //     try {
    //         const web3Conn = newConnection();
    //         const programId = spl.TOKEN_2022_PROGRAM_ID; // That was made for Sonic SVM. For Solana Mainnet we need to use spl.TOKEN_PROGRAM_ID + spl.TOKEN_2022_PROGRAM_ID

    //         const mainWalletPublicKey = new web3.PublicKey(walletAddress);
    //         const accounts = await web3Conn.getParsedTokenAccountsByOwner(mainWalletPublicKey, { programId });

    //         const mints = accounts.value.map((element) => element.account.data.parsed.info.mint);
    //         const assets = await MetaplexManager.fetchAllDigitalAssets(chain, mints);

    //         const balances: {mint: string, symbol?: string, name?: string, balance: TokenBalance}[] = [];
    //         for (const element of accounts.value) {
    //             if (
    //                 element.account.data.parsed.info.mint && 
    //                 element.account.data.parsed.info.tokenAmount.amount && 
    //                 element.account.data.parsed.info.tokenAmount.uiAmount &&
    //                 element.account.data.parsed.info.tokenAmount.decimals &&
    //                 element.pubkey
    //             ){
    //                 const mint = element.account.data.parsed.info.mint;
    //                 const asset = assets.find((asset) => asset.mint.publicKey == mint);
    //                 const symbol = asset ? asset.metadata.symbol : undefined;
    //                 const name = asset ? asset.metadata.name : undefined;

    //                 console.log('!mike', 'mint:', mint, 'symbol:', symbol, 'asset:', asset);

    //                 balances.push({
    //                     mint: mint,
    //                     symbol: symbol,
    //                     name: name,
    //                     balance: {
    //                         amount: new BN(element.account.data.parsed.info.tokenAmount.amount), 
    //                         uiAmount: +(element.account.data.parsed.info.tokenAmount.uiAmount),
    //                         decimals: element.account.data.parsed.info.tokenAmount.decimals,
    //                         ataPubKey: element.pubkey    
    //                     },
    //                 });
    //             }
    //         }

    //         return balances;
    //     }
    //     catch (err){
    //         // console.error('getWalletTokenBalance', err);
    //     }

    //     return [];
    // }

    // ---------------------
    private static recentBlockhash: web3.BlockhashWithExpiryBlockHeight | undefined;
    private static recentBlockhashUpdatedAt: Date | undefined;
    static async getRecentBlockhash(): Promise<web3.BlockhashWithExpiryBlockHeight> {
        await this.updateBlockhash();
        return SolanaManager.recentBlockhash!;    
    }
    static async updateBlockhash(){
        // if now is less than 15 seconds from last update, then skip
        const now = new Date();
        if (SolanaManager.recentBlockhashUpdatedAt && now.getTime() - SolanaManager.recentBlockhashUpdatedAt.getTime() < 15000){
            return;
        }

        try {
            const web3Conn = newConnection(undefined);
            SolanaManager.recentBlockhash = await web3Conn.getLatestBlockhash('confirmed');    
            SolanaManager.recentBlockhashUpdatedAt = now;
        }
        catch (err){
            console.error('updateBlockhash', err);
        }
    }
    

}