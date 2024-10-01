import { Controller, Get, Query } from '@nestjs/common';
import { BumouService } from './bumou.service';

@Controller('bumou')
export class BumouController {
  constructor(private readonly bumouService: BumouService) {}
  @Get('privacy-policy')
  getBumou(@Query('lang') lang: string): any {
    return this.bumouService.getPrivacyPolicy(lang);
  }

  @Get('account-deletion')
  getAccountDeletion(@Query('lang') lang: string): any {
    return this.bumouService.getAccountDeletion(lang);
  }
}
