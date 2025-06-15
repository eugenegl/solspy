import * as mongoose from 'mongoose';

export let Schema = mongoose.Schema;
export let ObjectId = mongoose.Schema.Types.ObjectId;
export let Mixed = mongoose.Schema.Types.Mixed;

export interface ISandwich extends mongoose.Document {
    tokenAddress: string;
    walletAddress: string;
    solDrained: string;
    txHashBuy: string;
    txHashSell: string;
    victimWalletAddress: string;
    victimAmountIn: string;
    victimTxHash: string;
    slot: number;
    timestamp: string;
    source: string;
    lp: string;

    createdAt?: Date;
}

export const SandwichSchema = new mongoose.Schema<ISandwich>({
    tokenAddress: { type: String },
    walletAddress: { type: String },
    solDrained: { type: String },
    txHashBuy: { type: String },
    txHashSell: { type: String },
    victimWalletAddress: { type: String },
    victimAmountIn: { type: String },
    victimTxHash: { type: String },
    slot: { type: Number },
    timestamp: { type: String },
    source: { type: String },
    lp: { type: String },

    createdAt: { type: Date },
});

SandwichSchema.index({ victimTxHash: 1 }, { unique: true });
SandwichSchema.index({ createdAt: -1 });

SandwichSchema.methods.toJSON = function () {
    return {
        tokenAddress: this.tokenAddress,
        walletAddress: this.walletAddress,
        solDrained: this.solDrained / 10 ** 9,
        txHashBuy: this.txHashBuy,
        txHashSell: this.txHashSell,
        victimWalletAddress: this.victimWalletAddress,
        victimAmountIn: this.victimAmountIn / 10 ** 9,
        victimTxHash: this.victimTxHash,
        slot: this.slot,
        source: this.source,
        createdAt: this.createdAt,
    };
};

export const Sandwich = mongoose.model<ISandwich>('sandwiches', SandwichSchema);