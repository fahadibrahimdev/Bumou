import { Module } from '@nestjs/common';
import { BumouController } from './bumou.controller';
import { BumouService } from './bumou.service';

@Module({
  controllers: [BumouController],
  providers: [BumouService]
})
export class BumouModule {}
