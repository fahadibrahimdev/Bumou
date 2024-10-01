import { ForbiddenException, Injectable } from '@nestjs/common';
import { AddCommentDto, CreatePostDto } from './dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { I18nContext, I18nService } from 'nestjs-i18n';
import { PaginationRequest } from 'src/utils';
import { Prisma, User } from '@prisma/client';
import { DefaultArgs } from '@prisma/client/runtime/library';

@Injectable()
export class MomentsService {
  constructor(
    private prisma: PrismaService,
    private readonly i18n: I18nService,
  ) {}

  async getUserPosts(
    currentUserId: string,
    userId: string,
    query: PaginationRequest,
  ) {
    let { page, size } = query;
    if (page < 1) {
      page = 1;
    }
    const skip = (page - 1) * size;

    const posts = await this.prisma.post.findMany({
      where: {
        userId,
        is_anonymous: false,
      },
      take: size,
      skip,
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        mediaAttachments: true,
        user: {
          select: {
            id: true,
            username: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
            userType: true,
          },
        },
        comments: {
          take: 3,
          orderBy: { createdAt: 'desc' },
          include: {
            user: {
              select: {
                id: true,
                username: true,
                firstName: true,
                lastName: true,
                profilePicture: true,
                userType: true,
              },
            },
          },
        },
        likes: {
          where: {
            userId: currentUserId,
          },
        },
      },
    });

    const postsWithExtras = posts.map((post) => {
      const numberOfLikes = post.total_likes;

      return {
        ...post,
        numberOfLikes,
        isLikeByMe: post.likes.length > 0,
      };
    });

    return postsWithExtras;
  }

  async getMyPosts(userId: string, query: PaginationRequest) {
    let { page, size } = query;
    if (page < 1) {
      page = 1;
    }
    const skip = (page - 1) * size;

    const posts = await this.prisma.post.findMany({
      where: {
        userId,
      },
      take: size,
      skip,
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        mediaAttachments: true,
        user: {
          select: {
            id: true,
            username: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
            userType: true,
          },
        },
        comments: {
          take: 3,
          orderBy: { createdAt: 'desc' },
          include: {
            user: {
              select: {
                id: true,
                username: true,
                firstName: true,
                lastName: true,
                profilePicture: true,
                userType: true,
              },
            },
          },
        },
        likes: {
          where: {
            userId,
          },
        },
      },
    });

    const postsWithExtras = posts.map((post) => {
      const numberOfLikes = post.total_likes;

      return {
        ...post,
        numberOfLikes,
        isLikeByMe: post.likes.length > 0,
      };
    });

    return postsWithExtras;
  }

  async createPost(userId: string, body: CreatePostDto) {
    if (!body || (body.mediaAttachments == null && body.text == null)) {
      throw new ForbiddenException(
        this.i18n.translate('t.please_attach_some_data_text_image_or_video', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    const post = await this.prisma.post.create({
      data: {
        text: body.text,
        userId: userId,
        is_anonymous: body.isAnonymous,
        mediaAttachments: {
          create: body.mediaAttachments,
        },
      },
    });
    return post;
  }

  async getPosts(
    userId: string,
    page: number,
    pageSize: number,
    isAnonymous: boolean = false,
  ) {
    try {
      if (page === 0) {
        throw new ForbiddenException(
          this.i18n.translate('t.page_must_be_greater_than_0', {
            lang: I18nContext.current().lang,
          }),
        );
      }
      const skip = (page - 1) * pageSize;
      const posts = await this.prisma.post.findMany({
        where: {
          OR: [
            { userId },
            {
              user: {
                OR: [
                  {
                    friends1: {
                      some: {
                        user2Id: userId,
                        status: 'ACCEPTED',
                      },
                    },
                  },
                  {
                    friends2: {
                      some: {
                        user1Id: userId,
                        status: 'ACCEPTED',
                      },
                    },
                  },
                ],
              },
            },
            isAnonymous ? { is_anonymous: true } : {},
          ],
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: pageSize,
        include: {
          mediaAttachments: true,
          user: {
            // Include user details for post owner
            select: {
              id: true,
              username: true,
              firstName: true,
              lastName: true,
              profilePicture: true,
              userType: true,
            },
          },
          comments: {
            take: 3, // Include the first 3 comments
            orderBy: { createdAt: 'desc' },
            include: {
              user: {
                select: {
                  id: true,
                  username: true,
                  firstName: true,
                  lastName: true,
                  profilePicture: true,
                  userType: true,
                },
              },
            },
          },
          likes: {
            where: {
              userId,
            },
          },
        },
      });

      const ananymousUser: User = await this.prisma.user.findFirst({
        where: {
          id: 'anonymous',
        },
      });

      // Calculate the number of likes and set the isLikeByMe flag
      const postsWithExtras = posts.map((post) => {
        const numberOfLikes = post.total_likes;

        if (post.is_anonymous) {
          post.user = ananymousUser;
        }

        return {
          ...post,
          numberOfLikes,
          isLikeByMe: post.likes.length > 0,
        };
      });

      return postsWithExtras;
    } catch (error) {
      throw new ForbiddenException(error.message);
    }
  }

  async addComment(userId: string, postId: string, body: AddCommentDto) {
    const post = await this.prisma.post.findFirst({
      where: { id: postId },
    });

    if (!post) {
      throw new ForbiddenException(
        this.i18n.translate('t.post_not_found', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    const comment = await this.prisma.comment.create({
      data: {
        text: body.comment,
        postId: postId,
        userId: userId,
      },
    });
    this.updateTotalComments(postId);
    return comment;
  }

  async getComments(postId: string, page: number, pageSize: number) {
    if (page === 0) {
      throw new ForbiddenException(
        this.i18n.translate('t.page_must_be_greater_than_0', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    const skip = (page - 1) * pageSize;

    const comments = await this.prisma.comment.findMany({
      where: { postId: postId },
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            firstName: true,
            lastName: true,
            profilePicture: true,
            userType: true,
          },
        },
      },
      skip,
      take: pageSize,
    });
    return comments;
  }

  async likePost(userId: string, postId: string) {
    const post = await this.prisma.post.findFirst({
      where: { id: postId },
    });

    if (!post) {
      throw new ForbiddenException(
        this.i18n.translate('t.post_not_found', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    const like = await this.prisma.like.findFirst({
      where: {
        userId: userId,
        postId: postId,
      },
    });

    if (like) {
      await this.prisma.like.delete({
        where: { id: like.id },
      });
      return {
        message: this.i18n.translate('t.post_unliked_successfuly', {
          lang: I18nContext.current().lang,
        }),
        isLikeByMe: false,
      };
    }

    await this.prisma.like.create({
      data: {
        postId: postId,
        userId: userId,
      },
    });
    this.updateTotalLikes(postId);
    return {
      message: this.i18n.translate('t.post_liked_successfuly', {
        lang: I18nContext.current().lang,
      }),
      isLikeByMe: true,
    };
  }

  async getLikes(postId: string, page: number, pageSize: number) {
    if (page === 0) {
      throw new ForbiddenException(
        this.i18n.translate('t.page_must_be_greater_than_0', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    const skip = (page - 1) * pageSize;

    const [likes, totalLikesCount] = await Promise.all([
      this.prisma.like.findMany({
        where: { postId: postId },
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              username: true,
              firstName: true,
              lastName: true,
              profilePicture: true,
              userType: true,
            },
          },
        },
        skip,
        take: pageSize,
      }),
      this.prisma.like.count({
        where: { postId: postId },
      }),
    ]);

    return { likes, totalLikesCount };
  }

  async deletePost(userId: string, postId: string) {
    const post = await this.prisma.post.findFirst({
      where: { id: postId },
    });

    if (!post) {
      throw new ForbiddenException(
        this.i18n.translate('t.post_not_found', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    if (post.userId !== userId) {
      throw new ForbiddenException(
        this.i18n.translate('t.you_are_not_allowed_to_delete_this_post', {
          lang: I18nContext.current().lang,
        }),
      );
    }

    await this.prisma.post.delete({
      where: { id: postId },
    });
    return {
      message: this.i18n.translate('t.post_deleted_successfuly', {
        lang: I18nContext.current().lang,
      }),
    };
  }

  private async updateTotalLikes(postId: string) {
    const aggregate = await this.prisma.like.aggregate({
      where: {
        postId,
      },
      _count: true,
    });

    await this.prisma.post.update({
      where: {
        id: postId,
      },
      data: {
        total_likes: aggregate._count,
      },
    });
  }

  private async updateTotalComments(postId: string) {
    const aggregate = await this.prisma.comment.aggregate({
      where: {
        postId,
      },
      _count: true,
    });

    await this.prisma.post.update({
      where: {
        id: postId,
      },
      data: {
        total_comments: aggregate._count,
      },
    });
  }
}
