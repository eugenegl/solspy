export interface TransactionStatus {
  status: Status;
  signature?: string;
  blockhash?: string;
  triesCount?: number;
  createdAt?: Date;
}

export enum Status {
  CREATED = 'CREATED',
  PROCESSING = 'PROCESSING',
  COMPLETED = 'COMPLETED',
  ERROR = 'ERROR'
}

export interface TransactionStatusResponse {
  id: string;
  signature?: string;
  status?: Status;
}

export enum Environment {
  PRODUCTION = 'PRODUCTION',
  DEVELOPMENT = 'DEVELOPMENT'
}

export interface WalletModel {
  publicKey: string; 
  privateKey: string;
}

export interface EncryptedWalletModel {
    publicKey: string; 
    data: string;
    iv: string;
    tag: string;
}

export enum AssetType {
  pNFT = 'pNFT',
  NFT = 'NFT',
  cNFT = 'cNFT',
  SOL = 'SOL',
  SPL = 'SPL',
  UNKNOWN = 'UNKNOWN'
}

export interface Asset {
    id: string;
    type: AssetType;
    title: string;
    image?: string;
    isDelegated?: boolean;
    collection?: {
        id: string,
        title?: string,
    };
    tags?: string[];
    infoline?: string;
    isStaked?: boolean;
    creators?: {
        address: string;
        share: number;
        verified: boolean;
    }[];
}

export interface Amount {
    amount: string;
    uiAmount: number;
    decimals: number;
}

export enum AddressType {
    TRANSACTION = 'TRANSACTION',
    WALLET = 'WALLET',
    TOKEN = 'TOKEN',
    TOKEN_ACCOUNT = 'TOKEN_ACCOUNT',
    PROGRAM = 'PROGRAM',
    STAKE_ACCOUNT = 'STAKE_ACCOUNT',
    VOTE_ACCOUNT = 'VOTE_ACCOUNT',
}