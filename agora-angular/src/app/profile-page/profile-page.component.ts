import { Component, OnInit } from '@angular/core';
import { products } from '../product-detail/test-data';
import { faEnvelope } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-profile-page',
  templateUrl: './profile-page.component.html',
  styleUrls: ['./profile-page.component.scss']
})
export class ProfilePageComponent implements OnInit {

  faEnvelope = faEnvelope;
  products = products;

  constructor() { }

  ngOnInit(): void {
  }

}
