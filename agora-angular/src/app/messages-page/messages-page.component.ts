import { Component, OnInit } from '@angular/core';
import {messages, contactList, Message} from '../services/messages'

@Component({
  selector: 'app-messages-page',
  templateUrl: './messages-page.component.html',
  styleUrls: ['./messages-page.component.scss']
})
export class MessagesPageComponent implements OnInit {

  messages = messages;

  constructor() { }

  contacts = contactList;

  ngOnInit(): void {
  }

}
