import express, { Request, Response } from "express";
import { Sandwich } from "../../entities/Sandwich";
import { query } from "express-validator";
import { validateRequest } from "../../middlewares/ValidateRequest";

const router = express.Router();

router.get(
    '/api/v1/sandwiches',
    [
        query('days').optional().isInt({ min: 1, max: 30 }).withMessage('Days must be between 1 and 30'),
    ],
    validateRequest,
    async (req: Request, res: Response) => {
		const days = req.query.days ? parseInt(req.query.days as string) : 30;
        const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

        const sandwiches = await Sandwich.find({ createdAt: { $gte: startDate } }).limit(100).sort({ createdAt: -1 });
        const sandwichesCount = await Sandwich.countDocuments({ createdAt: { $gte: startDate } });
        
        const solDrained = await Sandwich.aggregate([
            { $match: { createdAt: { $gte: startDate } } },
            { $group: { _id: null, solDrained: { $sum: { $toDouble: "$solDrained" } } } },
        ]);
        const victims = await Sandwich.distinct("victimWalletAddress", { createdAt: { $gte: startDate } });
        const attackers = await Sandwich.distinct("walletAddress", { createdAt: { $gte: startDate } });

		const response = {
            stats: {
                solDrained: solDrained[0].solDrained / 10 ** 9,
                sandwichesCount,
                victimsCount: victims.length,
                attackersCount: attackers.length,
            },
            sandwiches,
		};
        
		res.status(200).send(response);
    }
);

export { router as sandwichesRouter };
