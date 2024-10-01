import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { AddUsermoodDto } from './dto/add-usermood.dto';
import { UserMoodType } from '@prisma/client';
import { MomentsService } from 'src/moments/moments.service';
import { CreatePostDto } from 'src/moments/dto';
import { I18nContext, I18nService } from 'nestjs-i18n';

@Injectable()
export class UsermoodService {
  constructor(
    private prisma: PrismaService,
    private momentService: MomentsService,
    private readonly i18n: I18nService,
  ) {}

  async create(userId: string, payload: AddUsermoodDto) {
    const usermood = await this.prisma.userMood.create({
      data: {
        ...payload,
        userId,
      },
    });
    if (usermood) {
      const momentPost: CreatePostDto = {
        text: `${this.i18n.translate('t.i_m_feeling', {
          lang: I18nContext.current().lang,
        })} ${this.i18n.translate(`t.${usermood.mood}`, {
          lang: I18nContext.current().lang,
        })}. ${usermood.note || ''}`,
        isAnonymous: false,
      };

      const moment = await this.momentService.createPost(userId, momentPost);
    }
    return usermood;
  }

  async moodPercentOfDays(userId: string, previousDaysOf: number) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - previousDaysOf);

    const moodData = await this.prisma.userMood.findMany({
      where: {
        userId,
        createdAt: {
          gte: startDate,
        },
      },
    });

    // Create a map to store the counts of each mood type
    const moodCount = new Map<UserMoodType, number>();

    // Initialize the moodCount map with 0 counts for all mood types
    for (const moodType of Object.values(UserMoodType)) {
      moodCount.set(moodType, 0);
    }

    // Update the mood counts based on the retrieved data
    for (const moodEntry of moodData) {
      const moodType = moodEntry.mood;
      moodCount.set(moodType, moodCount.get(moodType) + 1);
    }

    const totalMoodEntries = moodData.length;

    // Calculate the percentage for each mood type
    const moodPercentages = Object.values(UserMoodType).map((mood) => ({
      mood,
      percentage: (moodCount.get(mood) / totalMoodEntries) * 100,
    }));

    return moodPercentages;
  }
}
