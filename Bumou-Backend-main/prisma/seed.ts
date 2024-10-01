import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';
import * as argon from 'argon2';

const prisma = new PrismaClient();

async function main() {
  dotenv.config();
  console.log('Seeding...');
  const superAdmin = await prisma.user.upsert({
    where: { email: 'anonymou@bumou.com' },
    update: {},
    create: {
      id: 'anonymous',
      email: 'anonymou@bumou.com',
      password: await argon.hash('11223344'),
      phone: '1234567890',
      firstName: 'Anonymous',
      lastName: 'User',
      isVerified: true,
      username: 'anonymous',
      profilePicture:
        'https://imageio.forbes.com/specials-images/imageserve/5ed68e8310716f0007411996/A-black-screen--like-the-one-that-overtook-the-internet-on-the-morning-of-June-2-/960x0.jpg',
    },
  });
  console.log({ superAdmin });
}

main()
  .catch((e) => console.error(e))
  .finally(async () => {
    await prisma.$disconnect();
  });
