import { Component, OnInit } from '@angular/core';
import { myProducts, profileDetail } from '../product-detail/test-data';
import { User, seller } from "../model/user";
import { Product, productListShort, myProductList } from "../model/product";
import { faEnvelope, faLink,  faLocationArrow, faCalendarAlt} from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-my-profile',
  templateUrl: './my-profile.component.html',
  styleUrls: ['./my-profile.component.scss']
})
export class MyProfileComponent implements OnInit {

  faEnvelope = faEnvelope;
  faLink = faLink;
  faLocationArrow = faLocationArrow;
  faCalendar = faCalendarAlt;

  products = myProductList;
  profileDetail=seller;

  constructor() { }

  ngOnInit(): void {
  }

}
