import axios from "axios";
import { Sandwich } from "../entities/Sandwich";

export interface SolStatzSandwich {
    date: string;
    token_address: string;
    wallet_address: string;
    sol_drained: number;
    tx_hash_buy: string;
    tx_hash_sell: string;
    victim_wallet_address: string;
    victim_amount_in: number;
    victim_tx_hash: string;
    slot: number;
    timestamp: string;
    source: string;
    lp: string;
}

export class SandwichManager {

    static async fetchSandwiches(): Promise<SolStatzSandwich[]> {
        try{
            const data = await axios.get('https://www.solstatz.com/api/mev/sandwich_events');
            console.log('solstatz data', data);
            const sandwiches: SolStatzSandwich[] = data.data;
            console.log('solstatz sandwiches.length', sandwiches.length);

            const victimTxHashes = sandwiches.map(sandwich => sandwich.victim_tx_hash);
            const existingSandwiches = await Sandwich.find({ victimTxHash: { $in: victimTxHashes } });
            const existingSandwichMap = new Map(existingSandwiches.map(sandwich => [sandwich.victimTxHash, sandwich]));

            for (const sandwich of sandwiches) {
                try {
                    const existingSandwich = existingSandwichMap.get(sandwich.victim_tx_hash);
                    if (existingSandwich) {
                        continue;
                    }
                    
                    const newSandwich = new Sandwich();
                    newSandwich.tokenAddress = sandwich.token_address;
                    newSandwich.walletAddress = sandwich.wallet_address;
                    newSandwich.solDrained = sandwich.sol_drained.toString();
                    newSandwich.txHashBuy = sandwich.tx_hash_buy;
                    newSandwich.txHashSell = sandwich.tx_hash_sell;
                    newSandwich.victimWalletAddress = sandwich.victim_wallet_address;
                    newSandwich.victimAmountIn = sandwich.victim_amount_in.toString();
                    newSandwich.victimTxHash = sandwich.victim_tx_hash;
                    newSandwich.slot = sandwich.slot;
                    newSandwich.timestamp = sandwich.timestamp;
                    newSandwich.source = sandwich.source;
                    newSandwich.lp = sandwich.lp;
                    newSandwich.createdAt = new Date(sandwich.timestamp);
                    await newSandwich.save();
                }
                catch (err) {
                    console.error(err);
                }
            }

            return sandwiches;    
        }
        catch (err) {
            console.error(err);
            return [];
        }
    }

}