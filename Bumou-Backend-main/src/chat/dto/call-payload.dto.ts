export enum CallType {
  OFFER = 'offer',
  ANSWER = 'answer',
  CANDIDATE = 'candidate',
}
export class CallDto {
  type: CallType;
  senderId: string;
  receiverId: string;
  isVideo: boolean = false;
  payload: any;
}
