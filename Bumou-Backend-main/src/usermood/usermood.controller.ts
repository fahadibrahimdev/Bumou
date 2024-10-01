import { Body, Controller, Get, ParseIntPipe, Post, Query, UseGuards, ValidationPipe } from '@nestjs/common';
import { UsermoodService } from './usermood.service';
import { GetUser } from 'src/decorator';
import { AddUsermoodDto } from './dto/add-usermood.dto';
import { JwtGuard } from 'src/auth/guard';

@UseGuards(JwtGuard)
@Controller('usermood')
export class UsermoodController {
    constructor(private usermoodService: UsermoodService) { }

    @Post()
    async create(@GetUser('id') userId: string, @Body(new ValidationPipe()) payload: AddUsermoodDto) {
        return this.usermoodService.create(userId, payload);
    }

    @Get('moodpercentofdays')
    async moodPercentOfDays(@GetUser('id') userId: string, @Query('previousDaysOf') previousDaysOf: number = 7) {
        return this.usermoodService.moodPercentOfDays(userId, previousDaysOf);
    }
}