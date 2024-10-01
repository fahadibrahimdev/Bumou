import { ForbiddenException, Injectable, Logger } from '@nestjs/common';
import { LoginDto, RegisterDto } from './dto';
import { PrismaService } from 'src/prisma/prisma.service';
import * as argon from 'argon2';
import { Prisma, User } from '@prisma/client';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { I18nService, I18nContext, logger } from 'nestjs-i18n';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
    private config: ConfigService,
    private readonly i18n: I18nService,
  ) {}

  verifyJwt(jwt: string): Promise<any> {
    return this.jwt.verifyAsync(jwt, {
      secret: this.config.get<string>('JWT_SECRET'),
    });
  }

  async getCurrentUser(user: User) {
    const access_token = await this.signToken(user);
    // await this._registerDevice( user.id);

    return { ...user, access_token };
  }

  async _registerDevice(pushy_token: string, userId: string) {
    const tokens = await this.prisma.userDeviceToken.findMany({
      where: {
        AND: [
          {
            token: { equals: pushy_token },
          },
          {
            userId: { equals: userId },
          },
        ],
      },
    });

    const logger = new Logger('AuthService');
    if (tokens.length == 0) {
      await this.prisma.userDeviceToken.create({
        data: {
          token: pushy_token,
          userId: userId,
        },
      });

      logger.debug('Token created successfully --> ' + pushy_token);
    } else {
      for (let i = 0; i < tokens.length; i++) {
        logger.debug(
          'Existing tokens -> ' + tokens[i].userId + ' ->' + tokens[i].token,
        );
      }
    }
  }

  async isUsernameAvailable(username: string) {
    const user = await this.prisma.user.findFirst({ where: { username } });
    return { isAvailable: !user };
  }

  async isEmailAvailable(email: string) {
    const user = await this.prisma.user.findFirst({ where: { email } });
    return { isAvailable: !user };
  }

  async isPhoneAvailable(phone: string) {
    const user = await this.prisma.user.findFirst({ where: { phone } });
    return { isAvailable: !user };
  }

  async register(registerDto: RegisterDto) {
    try {
      if (
        !registerDto.email ||
        registerDto.email == null ||
        registerDto.email === ''
      ) {
        registerDto.email = registerDto.username + '@bumou.com';
      }
      const hashedPassword = await argon.hash(registerDto.password);
      const withoutTokenData = { ...registerDto };
      // delete withoutTokenData.pushy_token;

      const user = await this.prisma.user.create({
        data: {
          ...withoutTokenData,
          password: hashedPassword,
        },
      });
      delete user.password;
      const access_token = await this.signToken(user);

      // await this._registerDevice(registerDto.pushy_token, user.id);
      return { ...user, access_token };
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === 'P2002') {
          throw new ForbiddenException(
            this.i18n.translate('t.user_already_exists', {
              lang: I18nContext.current().lang,
            }),
          );
        }
      }
      throw error;
    }
  }

  async login(loginDto: LoginDto) {
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { username: loginDto.username },
          { email: loginDto.username },
          { phone: loginDto.username },
        ],
      },
    });
    if (!user) {
      throw new ForbiddenException(
        this.i18n.translate('t.user_not_found', {
          lang: I18nContext.current().lang,
        }),
      );
    }
    const validPassword = await argon.verify(user.password, loginDto.password);
    if (!validPassword) {
      throw new ForbiddenException(
        this.i18n.translate('t.invalid_password', {
          lang: I18nContext.current().lang,
        }),
      );
    }
    delete user.password;
    const access_token = await this.signToken(user);

    // await this._registerDevice(loginDto.pushy_token, user.id);

    return { ...user, access_token };
  }

  async signToken(user: User): Promise<string> {
    const payload = {
      username: user.username,
      sub: user.id,
      userType: user.userType,
      email: user.email,
    };
    return this.jwt.signAsync(payload, {
      secret: this.config.get<string>('JWT_SECRET'),
      expiresIn: this.config.get<string>('JWT_EXPIRATION_TIME'),
    });
  }
}
