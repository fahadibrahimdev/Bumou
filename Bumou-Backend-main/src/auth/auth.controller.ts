import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto, RegisterDto } from './dto';
import { User } from '@prisma/client';
import { GetUser } from 'src/decorator';
import { JwtGuard } from './guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @HttpCode(HttpStatus.OK)
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @HttpCode(HttpStatus.OK)
  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @UseGuards(JwtGuard)
  @Get('current-user')
  getCurrentUser(@GetUser() user: User) {
    return this.authService.getCurrentUser(user);
  }

  @Get('is-username-available')
  async isUsernameAvailable(@Query('username') username: string) {
    return this.authService.isUsernameAvailable(username);
  }

  @Get('is-email-available')
  async isEmailAvailable(@Query('email') email: string) {
    return this.authService.isEmailAvailable(email);
  }

  @Get('is-phone-available')
  async isPhoneAvailable(@Query('phone') phone: string) {
    return this.authService.isPhoneAvailable(phone);
  }
}
