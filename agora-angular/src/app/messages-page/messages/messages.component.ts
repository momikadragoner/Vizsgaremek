import { Component, Input, OnInit } from '@angular/core';
import { faPaperPlane } from '@fortawesome/free-solid-svg-icons';
import { AuthService } from 'src/app/account-forms/services/auth.service';
import { Message, MessageService } from '../../services/messages.service';

@Component({
  selector: 'app-messages',
  templateUrl: './messages.component.html',
  styleUrls: ['./messages.component.scss'],
})
export class MessagesComponent implements OnInit {
  faPaperPlane = faPaperPlane;

  @Input() public messages: Message[] = [];
  @Input() public contactId: number = 22;
  message:string = '';
  currentUserId = this.authService.getUserDetails()[0].member_id;

  constructor(
    private messageService: MessageService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {}

  send(){
    let message = new Message();
    message.senderId = this.currentUserId;
    message.reciverId = this.contactId;
    message.message = this.message;
    this.messageService.insertMessages(message).subscribe({
      next: () => {
        this.message = '';
        this.messageService.getMessages(undefined, this.contactId).subscribe({
          next: (data) => {
            this.messages = [...data];
          }
        })
      }
    });
  }

  getStyle(id: number) {
    let message: Message = this.messages[id];
    let style: string = message.recived ? 'recived' : 'sent';
    if (id == 0) {
      if (message.recived && this.messages[id + 1].recived)
        style += ' recived-top';
      if (!message.recived && !this.messages[id + 1].recived)
        style += ' sent-top';
      return style;
    } else if (id == this.messages.length - 1) {
      if (message.recived && this.messages[id - 1].recived)
        style += ' recived-bottom';
      if (!message.recived && !this.messages[id - 1].recived)
        style += ' sent-bottom';
      return style;
    } else {
      let prevMessage: Message = this.messages[id - 1];
      let nextMessage: Message = this.messages[id + 1];
      if (message.recived && nextMessage.recived && prevMessage.recived) {
        style += ' recived-middle';
      } else if (
        message.recived &&
        nextMessage.recived &&
        !prevMessage.recived
      ) {
        style += ' recived-top';
      } else if (
        message.recived &&
        !nextMessage.recived &&
        prevMessage.recived
      ) {
        style += ' recived-bottom';
      } else if (
        !message.recived &&
        !nextMessage.recived &&
        prevMessage.recived
      ) {
        style += ' sent-top';
      } else if (
        !message.recived &&
        !nextMessage.recived &&
        !prevMessage.recived
      ) {
        style += ' sent-middle';
      } else if (
        !message.recived &&
        nextMessage.recived &&
        !prevMessage.recived
      ) {
        style += ' sent-bottom';
      }
      return style;
    }
  }
}
