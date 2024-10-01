import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Put,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guard';
import { UserService } from './user.service';
import { GetUser } from 'src/decorator';
import { UpdateUserDto } from './dto/update-user.dto';

@UseGuards(JwtGuard)
@Controller('users')
export class UserController {
  constructor(private userService: UserService) {}

  @Patch('update-user')
  async updateUser(
    @GetUser('id') userId: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.userService.updateUser(userId, updateUserDto);
  }

  @Get(':id')
  async getUserById(@Param('id') userId: string) {
    return this.userService.getUserById(userId);
  }

  @Get('search/:query')
  async searchUser(
    @GetUser('id') userId: string,
    @Param('query') query: string,
  ) {
    return this.userService.searchUser(userId, query);
  }

  @Delete()
  async deleteUser(@GetUser('id') userId: string) {
    return this.userService.deleteUser(userId);
  }

  @Put('help')
  async helpUser(@GetUser('id') userId: string, @Body() payload: any) {
    return await this.userService.updateIsHelping(userId, payload);
  }
}
