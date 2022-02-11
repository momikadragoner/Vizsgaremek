import { Component, OnInit } from '@angular/core';
import { User, seller, UserService } from "../services/user.service";
import { ProductShort as Product, ProductService } from "../services/product.service";
import { faEnvelope, faLink,  faLocationArrow, faCalendarAlt, faTimesCircle, faLockOpen, faLock, faEye, faEdit, faTrash} from '@fortawesome/free-solid-svg-icons';
import { ActivatedRoute } from '@angular/router';
import { FormBuilder } from '@angular/forms';
import { animate, style, transition, trigger } from '@angular/animations';
import { Auth } from '../services/auth';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-my-profile',
  templateUrl: './my-profile.component.html',
  styleUrls: ['./my-profile.component.scss'],
  animations: [
    trigger('tabChange', [
      transition(':increment', [
        style({ transform: 'translateX(-100%)'}),
        animate('0.3s',
          style({ transform: 'translateX(0)'}))
      ]),
      transition(':decrement', [
        style({ transform: 'translateX(100%)'}),
        animate('0.3s',
          style({ transform: 'translateX(0)'}))
      ]),
    ]),
    trigger('visibilityChange',[
      transition(':leave', [
        style({ opacity: 1}),
        animate('0.2s',
          style({ opacity: 0,}))
      ]),
      transition(':enter', [
        style({ opacity: 0}),
        animate('0.2s',
          style({ opacity: 1,}))
      ])
    ])
  ]
})
export class MyProfileComponent implements OnInit {

  order?:any;
  searchTerm?: string;
  currentUser = Auth.currentUser;

  orderOptions:string[] = ["Összes","Legújabb", "Legrégebbi", "Ár szerint csökkenő", "Ár szerint növekvő", "Készleten", "Közzétett", "Nincs közzétéve"];

  tabOpen = 1;
  alertOpen = false;
  moreOptionsOpen = false;

  faEnvelope = faEnvelope;
  faLink = faLink;
  faLocationArrow = faLocationArrow;
  faCalendar = faCalendarAlt;
  faTimesCircle = faTimesCircle;
  faEye = faEye;
  faLock = faLock;
  faLockOpen = faLockOpen;
  faEdit = faEdit;
  faTrash = faTrash;

  //products = myProductList;
  // profileDetail=seller;
  error: string = "";
  products: Product[] = [{productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''}];
  user: User = { userId: 0, firstName: '', lastName: '', following: -1, followers: -0, email: "", phone: "", about: "", profileImgUrl: "", headerImgUrl: "", registeredAt: new Date(), isVendor: false, isAdmin: false, companyName: undefined, takesCustomOrders: true };
  
  selectedProduct: Product = {productId: 0, name: "", sellerLastName: "", sellerFirstName: "", price: -1, imgUrl:''};

  constructor(
    private productService: ProductService, 
    private userService: UserService, 
    private route: ActivatedRoute,
    private fb: FormBuilder
  ) 
  { 
    this.ShowUser();
    this.ShowProducts(this.searchForm.value.order, this.searchForm.value.searchTerm);
  }

  orderSelect() {
    console.log(this.searchForm.value.order);
    this.ShowProducts(this.searchForm.value.order, this.searchForm.value.searchTerm);
  }

  searchChange() {
    console.log(this.searchForm.value.searchTerm)
    this.ShowProducts(this.searchForm.value.order, this.searchForm.value.searchTerm);
  }

  searchForm = this.fb.group({
    order: [this.order],
    searchTerm: [this.searchTerm]
  });

  ShowProducts(orderby?:string, term?:string) {
    this.productService.getMyProducts(orderby, term)
    .subscribe({
      next: (data: [Product]) => this.products = [...data], 
      error: error => this.error = error
    });
  }

  ngOnInit(): void {
  }

  ShowUser() {
    this.userService.getUser(this.currentUser.userId)
    .subscribe({
      next: (data: User) => this.user = {... data}, 
      error: error => this.error = error
    });
  }

  alertDeleteProduct(deleteId:number){
    this.alertOpen = true;
    this.products.forEach(product => {
      if(product.productId == deleteId){
        this.selectedProduct = product;
      }
    })
  }

  showMoreOptions(id:any){
    this.moreOptionsOpen = !this.moreOptionsOpen;
    this.products.forEach(product => {
      if(product.productId == id){
        this.selectedProduct = product;
      }
    })
  }

  deleteProduct($event:any){
    $event.preventDefault();
    this.productService.deleteProduct(this.selectedProduct.productId)
    .subscribe();
    this.products.splice(this.products.indexOf(this.selectedProduct),1);
    this.alertOpen = false;
    this.moreOptionsOpen = false;
  }

  makePublic($event:any, id:number){
    $event.preventDefault();
    this.productService.changeVisibility(true, id).subscribe();
    this.selectedProduct.isPublic = true;
    this.moreOptionsOpen = false;
  }

  makePrivate($event:any, id:number){
    $event.preventDefault();
    this.productService.changeVisibility(false, id).subscribe();
    this.selectedProduct.isPublic = false;
    this.moreOptionsOpen = false;
  }
}
