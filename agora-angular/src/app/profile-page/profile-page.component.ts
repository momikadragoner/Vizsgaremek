import { Component, OnInit } from '@angular/core';
import { ProductShort as Product, ProductService} from '../services/product.service';
import { User, seller } from "../services/user.service";
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

  products: Product[] = [{productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''}];
  error: string = "";
  user = seller;

  constructor(private productService: ProductService) { }

  ngOnInit(): void {
    this.ShowProductList();
  }

  ShowProductList() {
    this.productService.getProductListLong()
    .subscribe((data: [Product]) => this.products = [...data], error => this.error = error);
  }

}
