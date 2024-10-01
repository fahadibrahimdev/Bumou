import {
  PutObjectAclCommand,
  PutObjectAclCommandInput,
  PutObjectCommand,
  PutObjectCommandInput,
  PutObjectCommandOutput,
  S3Client,
} from '@aws-sdk/client-s3';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class UploadService {
  constructor(private readonly configService: ConfigService) {}

  private readonly stClient = new S3Client({
    region: this.configService.getOrThrow('AWS_S3_REGION'),
  });

  async uploadFile(file: Express.Multer.File, path?: string) {
    const currentDateTime = new Date().toISOString().replace(/:/g, '-');
    const fileName = `${currentDateTime}-${file.originalname}`;
    if (path) {
      path = path.replace(/^\/|\/$/g, '');
    }
    path = `app/${path}`;
    let key: string = path ? `${path}/${fileName}` : fileName;
    key = key.replace(/[^\w.-_]/g, '-');
    console.log('Upload key: ', key);

    const uploadParams: PutObjectCommandInput = {
      Bucket: 'bumoubucket',
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
      // ACL: 'public-read',
    };

    const uploadResult: PutObjectCommandOutput = await this.stClient.send(
      new PutObjectCommand(uploadParams),
    );

    // Set ACL to 'public-read'
    const aclParams: PutObjectAclCommandInput = {
      Bucket: 'bumoubucket',
      Key: key,
      ACL: 'public-read',
    };

    const aclResult = await this.stClient.send(
      new PutObjectAclCommand(aclParams),
    );

    // console.log("result: ", aclResult);
    return {
      url: `https://bumoubucket.s3.cn-northwest-1.amazonaws.com.cn/${key}`,
      ...uploadResult,
    };
  }
}
