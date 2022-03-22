import { Component, OnInit } from '@angular/core';
import { ProductShort as Product, ProductService, ProductShort } from '../services/product.service';
import { User, seller, UserService } from "../services/user.service";
import { faEnvelope, faLink, faLocationArrow, faCalendarAlt, faTrash, faHeart, faTimesCircle } from '@fortawesome/free-solid-svg-icons';
import { ActivatedRoute } from '@angular/router';
import { FormBuilder } from '@angular/forms';
import { animate, query, stagger, style, transition, trigger } from '@angular/animations';
import { WishListProduct, WishListService } from '../services/wishlist.service';
import { FollowService } from '../services/follow.service';

@Component({
  selector: 'app-profile-page',
  templateUrl: './profile-page.component.html',
  styleUrls: ['./profile-page.component.scss'],
  animations: [
    trigger('tabChange', [
      transition(':increment', [
        style({ transform: 'translateX(-100%)' }),
        animate('0.3s',
          style({ transform: 'translateX(0)' }))
      ]),
      transition(':decrement', [
        style({ transform: 'translateX(100%)' }),
        animate('0.3s',
          style({ transform: 'translateX(0)' }))
      ]),
    ]),
    trigger('visibilityChange', [
      transition(':leave', [
        style({ opacity: 1 }),
        animate('0.2s',
          style({ opacity: 0, }))
      ]),
      transition(':enter', [
        style({ opacity: 0 }),
        animate('0.2s',
          style({ opacity: 1, }))
      ])
    ])
  ]
})
export class ProfilePageComponent implements OnInit {

  faEnvelope = faEnvelope;
  faLink = faLink;
  faLocationArrow = faLocationArrow;
  faCalendar = faCalendarAlt;
  faTrash = faTrash;
  faHeart = faHeart
  faTimesCircle = faTimesCircle;

  tabOpen = 1;

  products: Product[] = [{ productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl: '' }];
  error: string = "";
  user: User = new User();
  wishList: WishListProduct[] = [new WishListProduct()];
  id: any;

  order?: any;
  searchTerm?: string;

  orderOptions: string[] = ["Összes", "Legújabb", "Legrégebbi", "Ár szerint csökkenő", "Ár szerint növekvő", "Készleten"];

  constructor(
    private productService: ProductService,
    private userService: UserService,
    private wishListService: WishListService,
    private followService: FollowService,
    private route: ActivatedRoute,
    private fb: FormBuilder
  ) {
    this.id = this.route.snapshot.paramMap.get('id');
    this.ShowUser(this.id);
    this.ShowProducts(this.id)
    this.ShowWishList(this.id);
  }

  ngOnInit(): void {

  }

  ShowUser(id: any) {
    this.userService.getUser(id)
      .subscribe({
        next: (data: User) => { this.user = { ...data } },
        error: error => this.error = error
      });
  }

  ShowProducts(id: any, orderby?: string, term?: string) {
    this.productService.getProductsBySeller(id, orderby, term)
      .subscribe({
        next: (data: [Product]) => this.products = [...data],
        error: error => this.error = error
      });
  }

  ShowWishList(id: any) {
    this.wishListService.getWishList(id)
      .subscribe({
        next: (data: [WishListProduct]) => this.wishList = [...data],
        error: error => this.error = error
      });
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

  follow($event: any, id: number) {
    $event.preventDefault();
    if (this.user.iFollow == undefined) {
      return console.log("Nem vagy bejelentkezve");
    }
    if (this.user.iFollow) {
      this.followService.deleteFollow(id).subscribe({
        next: data => {
          this.user.followers--;
          this.user.iFollow = false;
        }
      })
    }
    else if(this.user.iFollow == false){
      this.followService.postFollow(id).subscribe({
        next: data => {
          this.user.followers++;
          this.user.iFollow = true;
        }
      });
    }
  }

}
