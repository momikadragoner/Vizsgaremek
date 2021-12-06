import { Component, OnInit } from '@angular/core';
import { productListShort } from '../model/product';
import { User, seller } from "../model/user";
import { faEnvelope, faLink, faLocationArrow, faCalendarAlt} from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-profile-page',
  templateUrl: './profile-page.component.html',
  styleUrls: ['./profile-page.component.scss']
})
export class ProfilePageComponent implements OnInit {

  faEnvelope = faEnvelope;
  faLink = faLink;
  faLocationArrow = faLocationArrow;
  faCalendar = faCalendarAlt;

  products = productListShort;
  user = seller;

  constructor() { }

  ngOnInit(): void {
  }

}
