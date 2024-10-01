// // localization.middleware.ts
// import { Injectable, NestMiddleware } from '@nestjs/common';
// import { Request, Response } from 'express';
// import { I18nService, I18nContext } from 'nestjs-i18n';


// @Injectable()
// export class LocalizationMiddleware implements NestMiddleware {
//     constructor(private readonly i18n: I18nService) { }

//     use(req: Request, res: Response, next: Function) {
//         console.log("Language: " + req.headers['x-lang']);
//         const language = req.headers['x-lang'] || 'en_US'; // Default to en_US if not provided
//         // this.i18n.
//         // I18nContext.apply([language]);

//         console.log("Language: " + language);

//         next();
//     }
// }
