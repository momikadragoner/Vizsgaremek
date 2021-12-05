import { Component, OnInit } from '@angular/core';
import {profileDetail} from '../../product-detail/test-data';
import { faEnvelope, faLink, faLocationArrow, faCalendarAlt, faCamera} from '@fortawesome/free-solid-svg-icons';
import { User, seller } from "../../model/user";

@Component({
  selector: 'app-edit-profile',
  templateUrl: './edit-profile.component.html',
  styleUrls: ['./edit-profile.component.scss']
})
export class EditProfileComponent implements OnInit {

  faEnvelope = faEnvelope;
  faLink = faLink;
  faLocationArrow = faLocationArrow;
  faCalendar = faCalendarAlt;
  faCamera=faCamera;

  profileDetail=seller;

  constructor() { }

  ngOnInit(): void {
  }

}
