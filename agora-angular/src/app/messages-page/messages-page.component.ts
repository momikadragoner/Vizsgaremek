import { Component, OnInit } from '@angular/core';
import { faEnvelope } from '@fortawesome/free-solid-svg-icons';
import { Message, MessageService } from '../services/messages.service';
import { UserService, UserShort } from '../services/user.service';

@Component({
  selector: 'app-messages-page',
  templateUrl: './messages-page.component.html',
  styleUrls: ['./messages-page.component.scss'],
})
export class MessagesPageComponent implements OnInit {
  faEnvelope = faEnvelope;

  messages:Message[] = [];
  contacts:UserShort[] = [];
  selectedContact:UserShort = new UserShort();

  constructor(
    private messageService: MessageService,
    private userService: UserService
  ) { 
    messageService.getMessages(undefined, 22).subscribe({
      next: (data) => {
        this.messages = [...data];        
      }
    })
    userService.getContacts().subscribe({
      next: (data) => {
        this.contacts = [...data];
        console.log(this.contacts);
      }
    })
  }

  // contacts = contactList;

  ngOnInit(): void { }
}
