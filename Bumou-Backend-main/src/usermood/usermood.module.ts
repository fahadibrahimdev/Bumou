import { Module } from '@nestjs/common';
import { UsermoodController } from './usermood.controller';
import { UsermoodService } from './usermood.service';
import { MomentsModule } from 'src/moments/moments.module';

@Module({
  imports: [MomentsModule],
  controllers: [UsermoodController],
  providers: [UsermoodService]
})
export class UsermoodModule { }
