import { PageToken } from "../../models/PageToken";
import { Request } from "express";
import BN from "bn.js";

export class Helpers {

    static async sleep(seconds: number) {
        return new Promise(resolve => setTimeout(resolve, seconds * 1000));
    }
 
    static getRandomInt(min: number, max: number) {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    static getProbability(winProbability: number): boolean {
        return this.getRandomInt(1, 10000) <= winProbability * 100;
    }   

    static prettyNumber(n: number, roundDecimals?: number): string {
        if (roundDecimals != undefined){
            const tmp = 10 ** roundDecimals;

            // n = (n > 0 ? Math.floor(n * tmp) : Math.ceil(n * tmp)) / tmp;
            n = Math.round(n * tmp) / tmp;
        }
        return this.numberWithCommas(n);
    }

    static prettyNumberFromString(str: string, roundDecimals?: number): string {
        let n = +str;
        if (roundDecimals != undefined){
            const tmp = 10 ** roundDecimals;

            // n = (n > 0 ? Math.floor(n * tmp) : Math.ceil(n * tmp)) / tmp;
            n = Math.round(n * tmp) / tmp;
        }
        return this.numberWithCommas(n);
    }

    static padNumber(d: number): string {
        return (d < 10) ? '0' + d.toString() : d.toString();
    }

    static numberWithCommas(x: number): string {
        // return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        const [integerPart, decimalPart] = x.toString().split('.');
        const formattedInteger = Number(integerPart).toLocaleString('en-US');
        return decimalPart ? `${formattedInteger}.${decimalPart}` : formattedInteger;
    }

    static numberFormatter(num: number, digits: number): string {
        const lookup = [
          { value: 1, symbol: "" },
          { value: 1e3, symbol: "k" }, // Thousand
          { value: 1e6, symbol: "M" }, // Million
          { value: 1e9, symbol: "B" }, // Billion
          { value: 1e12, symbol: "T" }, // Trillion
          { value: 1e15, symbol: "Q" }, // Quadrillion
          { value: 1e18, symbol: "Qn" }, // Quintillion
        ];
        const rx = /\.0+$|(\.[0-9]*[1-9])0+$/;
        var item = lookup.slice().reverse().find(function(item) {
          return num >= item.value;
        });
        return item ? (num / item.value).toFixed(digits).replace(rx, "$1") + item.symbol : "0";
      }

    static getNextDayOfWeek(dayOfWeek: number, hours: number, minutes: number, seconds: number) {
        // Code to check that date and dayOfWeek are valid left as an exercise ;)

        if (dayOfWeek < 0 || dayOfWeek > 6) {
            throw new Error('dayOfWeek must be between 0 and 6');
        }

        const date = new Date();
        date.setHours(hours);
        date.setMinutes(minutes);
        date.setSeconds(seconds);
        date.setMilliseconds(0);

        const resultDate = new Date(date.getTime());    
        resultDate.setDate(date.getDate() + (7 + dayOfWeek - date.getDay()) % 7);
        return resultDate;
    }

    static getDateWithDaysInc(date: Date, daysInc: number) {
        const resultDate = new Date(date.getTime());    
        resultDate.setDate(date.getDate() + daysInc);
        return resultDate;
    }

    static isEmptyString(str: string | undefined): boolean {
        if (str && str!=null && str!='' && str!='null'){
            return false;
        }

        return true;
    }

    static prettyWallet(address: string): string {
        return address.substring(0, 4) + '...' + address.substring(address.length - 4, address.length);
    }

    static parsePageToken(req: Request): PageToken | undefined {
        let pageToken: PageToken | undefined;
        try {
            if (req.body?.pageToken != undefined){
                pageToken = PageToken.parse(req.body.pageToken.toString());
            }
            else if (req.query?.pageToken != undefined){
                pageToken = PageToken.parse(req.query.pageToken.toString());
            }
        }
        catch (err){}

        return pageToken;
    }

    static dateDiffString(date1: Date, date2: Date): string {
        const ms = Math.abs(date2.getTime() - date1.getTime());

        const days = Math.floor(ms / (24*60*60*1000));
        const daysms = ms % (24*60*60*1000);
        const hours = Math.floor(daysms / (60*60*1000));
        const hoursms = ms % (60*60*1000);
        const minutes = Math.floor(hoursms / (60*1000));
        const minutesms = ms % (60*1000);
        const sec = Math.floor(minutesms / 1000);

        const str = '';
        if (days > 0){
            return days + " days" + (hours > 0 ? ' ' + hours + ' hours' : '');
        }
        else if (hours > 0){
            return hours + " hours" + (minutes > 0 ? ' ' + minutes + ' minutes' : '');
        }
        else if (minutes > 0){
            return minutes + " minutes" + (sec > 0 ? ' ' + sec + ' seconds' : '');
        }
        else {
            return sec + " seconds";
        }
    }

    static htmlToPlainText(html: string): string {
        return html.replace(/<[^>]*>/g, '');
    }

    static makeid(length: number): string {
        let result = '';
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        const charactersLength = characters.length;
        let counter = 0;
        while (counter < length) {
          result += characters.charAt(Math.floor(Math.random() * charactersLength));
          counter += 1;
        }
        return result;
    }

    static bnToUiAmount(amount: BN, decimals: number): string {
        const bnDecimalsAmount = new BN(10 ** decimals);
        const { div, mod } = amount.divmod(bnDecimalsAmount);
        let result = div.toString();

        if (!mod.eqn(0)){
            result += '.';
            let modStr = mod.toString();
            const modStrLen = modStr.length;
            const zeros = decimals - modStrLen;
            for (let i = 0; i < zeros; i++) {
                result += '0';
            }

            // remove trailing zeros from modStr, since it's already after the decimal point
            while (modStr.length>0 && modStr[modStr.length - 1] == '0'){
                modStr = modStr.substring(0, modStr.length - 1);
            }

            result += modStr;
        }

        return result;
    }
    
    static isValidEmail(email: string): boolean {
        const res = email.match(
            /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        );
        return res ? true : false;
    };

    static bnDivBnWithDecimals(num1: BN, num2: BN, precision: number = 6): number {
        const lessThanZero = num1.lt(new BN(0));
        if (lessThanZero){
            num1 = num1.mul(new BN(-1));
        }

        try {
            const res = num1.mul(new BN(10 ** precision)).div(num2);
            // last precision digits
            const { div, mod } = res.divmod(new BN(10 ** precision));
            let result = div.toString();
            if (!mod.eqn(0)){
                result += '.';
                let modStr = mod.toString();
                const modStrLen = modStr.length;
                const zeros = precision - modStrLen;
                for (let i = 0; i < zeros; i++) {
                    result += '0';
                }
                // remove trailing zeros from modStr, since it's already after the decimal point
                while (modStr.length>0 && modStr[modStr.length - 1] == '0'){
                    modStr = modStr.substring(0, modStr.length - 1);
                }
                result += modStr;
            }
            let resultFloat = parseFloat(result);
            if (lessThanZero){
                resultFloat = -resultFloat;
            }
            return resultFloat;
        }
        catch (err){
            console.error('bnDivBnWithDecimals:', err);
            return 0;
        }
    }

}