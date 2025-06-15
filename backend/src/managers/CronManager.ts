import cron from 'node-cron';
import { SandwichManager } from './SandwichManager';

export class CronManager {
    constructor() {
        this.initCronJobs();
    }

    private initCronJobs() {
        cron.schedule('* * * * *', () => {
            console.log('Cron every minute');
            SandwichManager.fetchSandwiches();
        });
    }

}