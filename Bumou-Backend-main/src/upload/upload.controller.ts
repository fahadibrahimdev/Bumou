import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  MaxFileSizeValidator,
  ParseFilePipe,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UploadService } from './upload.service';

// @UseGuards(JwtGuard)
@Controller('upload')
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @HttpCode(HttpStatus.OK)
  @Post()
  @UseInterceptors(FileInterceptor('file'))
  uploadFile(
    @UploadedFile(
      new ParseFilePipe({
        validators: [new MaxFileSizeValidator({ maxSize: 524288000 })],
      }),
    )
    file: Express.Multer.File,
    @Body('path') path: string,
  ) {
    return this.uploadService.uploadFile(file, path);
  }
}
