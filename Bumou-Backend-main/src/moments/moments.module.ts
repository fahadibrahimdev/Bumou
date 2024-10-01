import { Module } from '@nestjs/common';
import { MomentsController } from './moments.controller';
import { MomentsService } from './moments.service';

@Module({
  controllers: [MomentsController],
  providers: [MomentsService],
  exports: [MomentsService]
})
export class MomentsModule { }
