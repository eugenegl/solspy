import express, { Request, Response } from "express";
import { validateRequest } from "../../middlewares/ValidateRequest";
import { body, query } from "express-validator";
import { AddressType } from "../../services/solana/types";
import { BadRequestError } from "../../errors/BadRequestError";
import { bs58 } from "@coral-xyz/anchor/dist/cjs/utils/bytes";
import { ParsedTransactionWithMeta, PublicKey, StakeProgram, SystemProgram, VoteProgram } from "@solana/web3.js";
import { newConnection } from "../../services/solana/lib/solana";
import { TOKEN_PROGRAM_ID } from "@solana/spl-token";
import { kProgramIdRaydium } from "../../services/solana/Constants";
import { Asset, SolanaManager } from "../../services/solana/SolanaManager";
import { Helpers } from "../../services/helpers/Helpers";
import { EnrichedTransaction } from "helius-sdk";
import { HeliusManager } from "../../services/solana/HeliusManager";

const router = express.Router();

router.get(
    '/api/v1/search',
    [
        query('address').notEmpty().withMessage('Address must be valid')
    ],
    validateRequest,
    async (req: Request, res: Response) => {
		const address = '' + req.query.address;
        let addressType: AddressType | undefined = undefined;
        const connection = newConnection();
        let balance: Asset | undefined = undefined;
        let assets: Asset[] | undefined = undefined;
        let transactions: EnrichedTransaction[] | undefined;
        let transaction: EnrichedTransaction | undefined = undefined;

        try {
            if (bs58.decode(address).length == 64){
                addressType = AddressType.TRANSACTION;
            }
            else {

                const pubkey = new PublicKey(address);
                const info = await connection.getAccountInfo(pubkey, 'confirmed');
                if (info == null){
                    throw new BadRequestError('Unknown address');
                }

                if (info.executable){
                    addressType = AddressType.PROGRAM;
                }
                else if (info.owner.toString() == StakeProgram.programId.toString()){
                    addressType = AddressType.STAKE_ACCOUNT;
                }
                else if (info.owner.toString() == VoteProgram.programId.toString()){
                    addressType = AddressType.VOTE_ACCOUNT;
                }
                else if (info.owner.toString() == SystemProgram.programId.toString()){
                    addressType = AddressType.WALLET;
                }
                else if (info.owner.toString() == TOKEN_PROGRAM_ID.toString()){
                    if (info.data.length == 82){
                        addressType = AddressType.TOKEN;
                    }
                    else if (info.data.length == 165){
                        addressType = AddressType.TOKEN_ACCOUNT;
                    }
                }

                console.log('info', info);
                console.log('data.length', info.data.length);
                

            }
        }
        catch (err) {
            throw new BadRequestError('Unknown address');
        }

        if (addressType == undefined){
            throw new BadRequestError('Unknown address');
        }

        if (addressType == AddressType.WALLET){
            try {
                const assetsInfo = await SolanaManager.getAssetsByOwner(address);
                if (assetsInfo){
                    balance = assetsInfo.sol;
                    assets = assetsInfo.assets;
                }    
                await Helpers.sleep(1);
                transactions = await SolanaManager.getLatestTransactions(address, 10);
            }
            catch (err) {
                console.error('getAssetsByOwner', err);
            }
        }
        else if (addressType == AddressType.TRANSACTION){
            const txs = await HeliusManager.getTransactions([address]);
            if (txs && txs.length > 0){
                transaction = txs[0];
            }
        }

        console.log('assets.length', assets?.length);
        
		const response = {
            address,
            type: addressType,
            balance: balance,
            assets: assets,
            transactions: transactions,
            transaction: transaction,
		};
        

		res.status(200).send(response);
    }
);

export { router as searchRouter };
