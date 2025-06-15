import { Sandwich } from "../entities/Sandwich";
import { SolanaManager } from "./solana/SolanaManager";

export class MigrationManager {

    static async migrate() {
        console.log('MigrationManager', 'migrate', 'start');

        const count = await Sandwich.countDocuments();
        console.log('Sandwiches count:', count);
    
        console.log('MigrationManager', 'migrate', 'done');
    }

}