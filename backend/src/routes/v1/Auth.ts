import express, { Request, Response } from "express";
import { validateRequest } from "../../middlewares/ValidateRequest";
import { body } from "express-validator";

const router = express.Router();

// router.post(
//     '/api/v1/auth',
//     [
//         body('email').isEmail().withMessage('Email must be valid')
//     ],
//     validateRequest,
//     async (req: Request, res: Response) => {
// 		const email = '' + req.body.email;

//         const authId = await AuthManager.createAuth(email);

// 		const response = {
// 			id: authId
// 		};
	
// 		res.status(200).send(response);
//     }
// );

export { router as authRouter };
