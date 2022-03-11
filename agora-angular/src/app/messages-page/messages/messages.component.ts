import { Component, Input, OnInit } from '@angular/core';
import { faPaperPlane } from '@fortawesome/free-solid-svg-icons';
import { Message } from '../../services/messages'

@Component({
  selector: 'app-messages',
  templateUrl: './messages.component.html',
  styleUrls: ['./messages.component.scss']
})
export class MessagesComponent implements OnInit {

  faPaperPlane = faPaperPlane;

  @Input() public messages: Message[] = [];

  constructor() { }

  ngOnInit(): void {
  }

  getStyle(id: number) {
    let message:Message = this.messages[id];
    let style:string = message.recived ? 'recived' : 'sent';
    if (id == 0) {
      if (message.recived == true && this.messages[id +1].recived == false) style = "recived";
    }
    else if (id == (this.messages.length - 1)) {

    }
    else {
      let prevMessage:Message = this.messages[id - 1];
      let nextMessage:Message = this.messages[id + 1];
      if (this.messages[id - 1]) {

      }
    }
  }

}
