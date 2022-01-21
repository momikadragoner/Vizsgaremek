import { Component, OnInit } from '@angular/core';
import { ProductShort as Product, ProductService} from '../services/product.service';
import { User, seller, UserService } from "../services/user.service";
import { faEnvelope, faLink, faLocationArrow, faCalendarAlt, faTrash, faHeart} from '@fortawesome/free-solid-svg-icons';
import { ActivatedRoute } from '@angular/router';
import { FormBuilder } from '@angular/forms';

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
  faTrash = faTrash;
  faHeart = faHeart

  tabOpen = 1;

  products: Product[] = [{productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''}];
  error: string = "";
  user: User = { userId: 0, firstName: '', lastName: '', following: -1, followers: -0, email: "", phone: "", about: "", profileImgUrl: "", headerImgUrl: "", registeredAt: new Date(), isVendor: false, isAdmin: false, companyName: undefined, takesCustomOrders: true };
  id:any;

  order?:any;
  searchTerm?: string;

  orderOptions:string[] = ["Legújabb", "Legrégebbi", "Ár szerint csökkenő", "Ár szerint növekvő", "Készleten"];

  constructor(
    private productService: ProductService, 
    private userService: UserService, 
    private route: ActivatedRoute,
    private fb: FormBuilder
    ) { }

  ngOnInit(): void {
    this.id = this.route.snapshot.paramMap.get('id');
    this.ShowUser(this.id);
  }

  ShowUser(id:any) {
    this.userService.getUser(id)
    .subscribe((data: User) => {this.user = {... data}; this.ShowProducts(this.user.userId)}, error => this.error = error);
  }

  ShowProducts(id:any, orderby?:string, term?:string) {
    this.productService.getProductsBySeller(id, orderby, term)
    .subscribe((data: [Product]) => this.products = [...data], error => this.error = error);
  }

  orderSelect() {
    console.log(this.searchForm.value.order);
    this.ShowProducts(this.user.userId, this.searchForm.value.order, this.searchForm.value.searchTerm);
  }

  searchChange() {
    console.log(this.searchForm.value.searchTerm)
    this.ShowProducts(this.user.userId, this.searchForm.value.order, this.searchForm.value.searchTerm);
  }

  searchForm = this.fb.group({
    order: [this.order],
    searchTerm: [this.searchTerm]
  });

}
