import { AddressLookupTableAccount, Keypair, TransactionInstruction } from '@solana/web3.js';
import { DAS, EnrichedTransaction, Helius, SmartTransactionContext } from "helius-sdk";
import { HeliusAsset, HeliusAssetDisplayOptions, MintApiResult } from './HeliusTypes';
import { Asset, AssetType } from './types';
import axios from 'axios';

export interface TokenHolder {
    owner: string;
    account: string;
    amount: string;
    uiAmount: number;
}

export class HeliusManager {

    static apiUrl = `https://mainnet.helius-rpc.com/?api-key=${process.env.HELIUS_API_KEY}`;
    static helius: Helius;

    static async initHelius(){
        if (!this.helius){
            this.helius = new Helius(process.env.HELIUS_API_KEY!);
        }
    }

    static async getTransaction(signature: string): Promise<EnrichedTransaction | undefined> {
        this.initHelius();

        const apiEndpoint = this.helius.getApiEndpoint('/v0/transactions');
        const result = await axios.post(apiEndpoint, {
            transactions: [signature],
        });
        return result.data[0] || undefined;
    }

    static async getAssetsByOwner(walletAddress: string, options: DAS.DisplayOptions, page = 1): Promise<{items: DAS.GetAssetResponse[], nativeBalance?: DAS.NativeBalanceInfo}> {
        try{
            this.initHelius();

            if (page > 1){
                options.showNativeBalance = false;
            }

            const limit = 1000;
            const response = await this.helius.rpc.getAssetsByOwner({
                ownerAddress: walletAddress,
                page: page, // Starts at 1
                limit: limit,
                displayOptions: options,
            });
            const items = response.items;

            if (items.length == limit && page < 3){
                const next = await this.getAssetsByOwner(walletAddress, options, page+1);
                items.push(...next.items);
            }

            return { items, nativeBalance: response.nativeBalance };
        }
        catch (e){
            console.error('getAssetsByOwner', e);
            return { items: [] };
        }
    }

    static async getAsset(mintToken: string, displayOptions: HeliusAssetDisplayOptions): Promise<HeliusAsset | undefined> {
        try {
            const response = await fetch(this.apiUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    jsonrpc: '2.0',
                    id: 'my-id',
                    method: 'getAsset',
                    params: {
                        id: mintToken,
                        displayOptions: {​
                            showUnverifiedCollections: true,​
                            showCollectionMetadata: false,​
                            showFungible: false,​
                            showInscription: false​
                        }
                    },
                }),
            });
            const { result } = await response.json() as any;
            return result;
        }
        catch (e){
            console.error('getAsset', e);
            return undefined;
        }
    };

    static parseAssets(assets: HeliusAsset[]): Asset[] {
        const parsedAssets: Asset[] = [];

        for (const asset of assets){
            const parsedAsset = this.parseAsset(asset);
            if (parsedAsset) {
                parsedAssets.push(parsedAsset);
            }
        }

        return parsedAssets;
    }

    static parseAsset(asset: HeliusAsset): Asset | undefined {
        const imagesMimeTypes = ['image/png', 'image/jpeg', 'image/gif', 'image/webp'];
        // console.log(process.env.SERVER_NAME, 'asset', JSON.stringify(asset));

        if (asset.burnt) { return undefined; }

        let assetType = AssetType.UNKNOWN;
        if (asset.interface == 'ProgrammableNFT'){
            assetType = AssetType.pNFT;
        }
        else if (asset.compression.compressed){
            assetType = AssetType.cNFT;
        }
        else if (asset.interface == 'Custom'){
            assetType = AssetType.NFT;
        }
        else if (asset.interface == 'V1_NFT'){
            assetType = AssetType.NFT;
        }
        else {
            return undefined;
        }

        const collection = asset.grouping.find(g => g.group_key == 'collection');

        const parsedAsset: Asset = {
            id: asset.id,
            type: assetType,
            title: asset.content.metadata.name.trim(),
            image: asset.content.files.find(f => imagesMimeTypes.includes(f.mime))?.uri,
            isDelegated: this.isAssetLocked(asset),
            collection: collection?.group_value ? { id: collection?.group_value } : undefined,
            creators: asset.creators,
        };

        return parsedAsset;
    }

    static isAssetLocked(asset: HeliusAsset): boolean {
        if (asset.interface == 'ProgrammableNFT'){
            return asset.ownership.delegated;
        }
        else {
            return asset.ownership.frozen;
        }
    }

    static recentPrioritizationFees: { fee: number, date: Date } | undefined;
    static async getRecentPrioritizationFees(forceCleanCache = false): Promise<number> {
        console.log(process.env.SERVER_NAME, 'getRecentPrioritizationFees');
        
        if (!forceCleanCache && this.recentPrioritizationFees && (new Date().getTime() - this.recentPrioritizationFees.date.getTime()) < 15 * 1000){
            return this.recentPrioritizationFees.fee;
        }

        let maxMicroLamports = 100_000_000;

        let fees = maxMicroLamports;

        try{
            const response = await fetch(this.apiUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    jsonrpc: "2.0",
                    id: 1,
                    method: "getPriorityFeeEstimate",
                    params: [{
                        "accountKeys": ["JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4"],
                        "options": {
                            "recommended": true,
                        }
                    }]
                }),
            });

            const { result } = await response.json() as any;

            // if (result?.priorityFeeLevels?.high){
            //     fees = Math.ceil(result.priorityFeeLevels.high);
            // }

            fees = Math.ceil(result.priorityFeeEstimate * 1.5);

            if (fees >= maxMicroLamports){ fees = maxMicroLamports; }

            this.recentPrioritizationFees = { fee: fees, date: new Date() };
        }
        catch(e){
            console.error('getRecentPrioritizationFees', e);
        }

        return fees;
    };

    static async sendSmartTransaction(instructions: TransactionInstruction[], keypair: Keypair, lookupTables?: AddressLookupTableAccount[], tipsLamports?: number){
        this.initHelius();

        try{
            const transactionSignature = await this.helius.rpc.sendSmartTransaction(instructions, [keypair], lookupTables, {skipPreflight: true, maxRetries: 0, lastValidBlockHeightOffset: 0});
            console.log(`Helius sendSmartTransaction - Successful transfer: ${transactionSignature}`);    
        }
        catch (err){
            console.error('Helius sendSmartTransaction', err);
        }
    }

    static async createSmartTransaction(instructions: TransactionInstruction[], keypair: Keypair, lookupTables?: AddressLookupTableAccount[]): Promise<SmartTransactionContext | undefined> {
        this.initHelius();

        try{
            const txContext = await this.helius.rpc.createSmartTransaction(instructions, [keypair], lookupTables);
            console.log(`Helius createSmartTransaction txContext: ${txContext}`);    
            return txContext;
        }
        catch (err){
            console.error('Helius createSmartTransaction', err);
        }
    }

    static async getTokenHolders(mint: string, includeEmpty: Boolean = false, includeSpecialWallets: Boolean = false): Promise<TokenHolder[]> {
        this.initHelius();

        const res = await this.helius.rpc.getTokenHolders(mint);
        // console.log(process.env.SERVER_NAME, 'getTokenHolders res', JSON.stringify(res, null, 2));

        const holders: TokenHolder[] = [];

        for (const item of res) {
            if ('parsed' in item.account.data){
                const owner = item.account.data.parsed.info.owner;
                if (item.account.data.parsed.info.tokenAmount.amount != '0' || includeEmpty){
                    if (!includeSpecialWallets){
                        continue;
                    }

                    holders.push({
                        owner: owner,
                        account: item.pubkey.toBase58(),
                        amount: item.account.data.parsed.info.tokenAmount.amount,
                        uiAmount: item.account.data.parsed.info.tokenAmount.uiAmount,
                    });
                }
            }
        }

        // sort by uiAmount
        holders.sort((a, b) => b.uiAmount - a.uiAmount);

        return holders
    }

    static async getTokensPrices(mints: string[]): Promise<{address: string, price: number}[]> {
        console.log('HeliusManager', 'getTokensPrices', mints);
        if (mints.length == 0){ return []; }

        const prices: {address: string, price: number}[] = [];

        try {
            this.initHelius();

            const response = await this.helius.rpc.getAssetBatch({
                ids: mints,
                displayOptions: {
                    showUnverifiedCollections: false,
                    showCollectionMetadata: false,
                    showFungible: true,
                    showInscription: true,
                }
            })

            if (response && response.length > 0){
                for (const asset of response) {
                    const price_info = asset?.token_info?.price_info;
                    if (price_info){
                        prices.push({
                            address: asset.id,
                            price: price_info.price_per_token,
                        });
                    }
                }
            }

        }
        catch (e: any){
            const errorMessage = e?.response?.data?.message || e?.message || 'Unknown error';
            console.error('HeliusManager', 'getTokensPrices', 'error', errorMessage);
        }

        return prices;
    }

}