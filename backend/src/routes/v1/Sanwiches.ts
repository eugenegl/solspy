import express, { Request, Response } from "express";
import { Sandwich } from "../../entities/Sandwich";

const router = express.Router();

router.get(
    '/api/v1/sandwiches',
    async (req: Request, res: Response) => {
		const sandwiches = await Sandwich.find({}).limit(100).sort({ createdAt: -1 });

		const response = {
            sandwiches,
		};
        
		res.status(200).send(response);
    }
);

export { router as sandwichesRouter };
