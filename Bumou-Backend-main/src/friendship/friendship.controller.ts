import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guard';
import { FriendshipService } from './friendship.service';
import { GetUser } from 'src/decorator';
import { AddFriendDto } from './dto';
import { UpdateFriendshipDto } from './dto/update-friendship.dto';
import { User } from '@prisma/client';

@UseGuards(JwtGuard)
@Controller('friendship')
export class FriendshipController {
  constructor(private friendshipService: FriendshipService) {}

  @HttpCode(HttpStatus.OK)
  @Post('/add')
  async addFriend(@GetUser() user: User, @Body() addFriendDto: AddFriendDto) {
    return this.friendshipService.addFriend(user, addFriendDto);
  }

  @Get('/pending')
  async getPendingFriendship(@GetUser('id') userId: string) {
    return this.friendshipService.getPendingFriendship(userId);
  }
  @Get('/suggestions')
  async getFriendSuggestions(
    @GetUser() user: User,
    @Query('page', ParseIntPipe) page: number = 1,
    @Query('pageSize', ParseIntPipe) pageSize: number = 20,
  ) {
    return this.friendshipService.getFriendSuggestions(user, page, pageSize);
  }

  @HttpCode(HttpStatus.OK)
  @Patch('/update')
  async acceptFriendship(
    @GetUser() user: User,
    @Body() body: UpdateFriendshipDto,
  ) {
    return this.friendshipService.acceptFriendship(user, body);
  }

  @HttpCode(HttpStatus.OK)
  @Patch('/remove-friend/:friendId')
  async removeFriend(
    @GetUser() user: User,
    @Param('friendId') friendId: string,
  ) {
    return this.friendshipService.removeFriend(user, friendId);
  }

  @Get()
  async getFriendships(@GetUser('id') userId: string) {
    return this.friendshipService.getFriendships(userId);
  }
}
