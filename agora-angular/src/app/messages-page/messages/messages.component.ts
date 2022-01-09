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

  @Input() public messages:Message[] = [];

  constructor() { }

  ngOnInit(): void {
  }

}
