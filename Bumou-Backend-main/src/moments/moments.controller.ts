import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { MomentsService } from './moments.service';
import { GetUser } from 'src/decorator';
import { AddCommentDto, CreatePostDto } from './dto';
import { JwtGuard } from 'src/auth/guard';
import { PaginationRequest } from 'src/utils';

@UseGuards(JwtGuard)
@Controller('moments')
export class MomentsController {
  constructor(private momentService: MomentsService) {}

  @Get('my')
  async getMyPosts(
    @GetUser('id') currentUserId: string,
    @Query() query: PaginationRequest,
  ) {
    return await this.momentService.getMyPosts(currentUserId, query);
  }

  @Get('user/:id')
  async getUserPosts(
    @GetUser('id') currentUserId: string,
    @Param('id') userId: string,
    @Query() query: PaginationRequest,
  ) {
    return await this.momentService.getUserPosts(currentUserId, userId, query);
  }

  @HttpCode(HttpStatus.OK)
  @Post()
  async createPost(@GetUser('id') userId: string, @Body() body: CreatePostDto) {
    return this.momentService.createPost(userId, body);
  }

  @Get()
  async getPosts(
    @GetUser('id') userId: string,
    @Query('page', ParseIntPipe) page: number = 1,
    @Query('pageSize', ParseIntPipe) pageSize: number = 20,

    @Query('isAnonymous') isAnonymous: boolean = false,
  ) {
    return this.momentService.getPosts(userId, page, pageSize, isAnonymous);
  }

  @HttpCode(HttpStatus.OK)
  @Post(':postId/comment')
  async addComment(
    @GetUser('id') userId: string,
    @Param('postId') postId: string,
    @Body() body: AddCommentDto,
  ) {
    return this.momentService.addComment(userId, postId, body);
  }

  @Get(':postId/comments')
  async getComments(
    @Param('postId') postId: string,
    @Query('page', ParseIntPipe) page: number = 1,
    @Query('pageSize', ParseIntPipe) pageSize: number = 20,
  ) {
    return this.momentService.getComments(postId, page, pageSize);
  }

  @HttpCode(HttpStatus.OK)
  @Post(':postId/like')
  async likePost(
    @GetUser('id') userId: string,
    @Param('postId') postId: string,
  ) {
    return this.momentService.likePost(userId, postId);
  }

  @Get(':postId/likes')
  async getLikes(
    @Param('postId') postId: string,
    @Query('page', ParseIntPipe) page: number = 1,
    @Query('pageSize', ParseIntPipe) pageSize: number = 20,
  ) {
    return this.momentService.getLikes(postId, page, pageSize);
  }

  @Delete(':postId')
  async deletePost(
    @GetUser('id') userId: string,
    @Param('postId') postId: string,
  ) {
    return this.momentService.deletePost(userId, postId);
  }
}
