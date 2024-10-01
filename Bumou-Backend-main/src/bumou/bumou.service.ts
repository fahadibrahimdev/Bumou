import { Injectable } from '@nestjs/common';
import { englishPrivacy, chinesePrivacy } from './privacy';
import {
  chineseAccountDeletion,
  englishAccountDeletion,
} from './account-deletion';
@Injectable()
export class BumouService {
  getPrivacyPolicy(lang = 'en'): any {
    switch (lang) {
      case 'en':
        return englishPrivacy;
      default:
        return chinesePrivacy;
    }
  }

  getAccountDeletion(lang: string): any {
    switch (lang) {
      case 'en':
        return englishAccountDeletion;
      default:
        return chineseAccountDeletion;
    }
  }
}
