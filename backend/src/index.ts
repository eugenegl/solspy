import express from 'express';
import 'express-async-errors';
import { json } from 'body-parser';
import 'reflect-metadata';
import cors, { CorsOptions } from 'cors';
import mongoose from 'mongoose';

import './services/helpers/Secrets'
import { NotFoundError } from './errors/NotFoundError';
import { errorHandler } from './middlewares/ErrorHandler';

import { MigrationManager } from './services/MigrationManager';
import { searchRouter } from './routes/v1/Search';
import { AccessToken } from './models/AccessToken';

import { CronManager } from './managers/CronManager';
import { Sandwich } from './entities/Sandwich';
import { sandwichesRouter } from './routes/v1/Sanwiches';

const corsOptions: CorsOptions = {
    allowedHeaders: ['Content-Type', 'Authorization'],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // 'PATCH', 'HEAD'
    origin: '*',
    optionsSuccessStatus: 204,
}

const app = express();
app.use(json());
app.use(cors(corsOptions));
app.options('*', cors(corsOptions));

declare global {
  namespace Express {
    interface Request {
      accessToken?: AccessToken,
    }
  }
}

if (process.env.API_ENABLED == 'true') {
    app.use(searchRouter);
    app.use(sandwichesRouter);
}

app.all('*', async () => {
    throw new NotFoundError();
});

app.use(errorHandler);

const start = async () => {
    console.log('Start');
    await mongoose.connect(process.env.MONGODB_CONNECTION_URL!);
    console.log('Connected to mongo');
    new CronManager();

    Sandwich.syncIndexes();

    const port = process.env.PORT;
    app.listen(port, () => {
        console.log(`Listening on port ${port}.`);
        onExpressStarted();


    });
}

const onExpressStarted = async () => {
    await MigrationManager.migrate();
}

start();