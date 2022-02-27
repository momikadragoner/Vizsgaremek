import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { faEnvelope, faLink, faLocationArrow, faCalendarAlt, faCamera} from '@fortawesome/free-solid-svg-icons';
import { User, seller } from "../../services/user.service";

@Component({
  selector: 'edit-profile',
  templateUrl: './edit-profile.component.html',
  styleUrls: ['./edit-profile.component.scss']
})
export class EditProfileComponent implements OnInit {

  faEnvelope = faEnvelope;
  faLink = faLink;
  faLocationArrow = faLocationArrow;
  faCalendar = faCalendarAlt;
  faCamera=faCamera;

  @Input() user: User = new User();
  @Output() modalState = new EventEmitter<boolean>();
  //@Output() userSent = new EventEmitter<User>();

  constructor() { }

  back($event: any) {
    $event.preventDefault();
    this.modalState.emit(false);
  }

  ngOnInit(): void {
  }

}
