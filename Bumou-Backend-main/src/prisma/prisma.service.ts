import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient {
  private readonly logger = new Logger(PrismaService.name);

  constructor(config: ConfigService) {
    super({
      datasources: {
        db: {
          url: config.get<string>('DATABASE_URL'),
        },
      },
    });

    this.$connect()
      .then(() => {
        this.logger.log('Connected to the database');
      })
      .catch((error) => {
        this.logger.error(`Error connecting to the database: ${error.message}`);
      });
  }
  async onModuleDestroy() {
    console.log('disconnected from database');
    await this.$disconnect();
  }
}
