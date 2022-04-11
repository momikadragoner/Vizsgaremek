import { Component, OnInit } from '@angular/core';
import { trigger, state, style, animate, transition, query, stagger } from '@angular/animations';
import { faCarrot, faAppleAlt, faBreadSlice, faCheese, faBell, IconPrefix, faDrumstickBite, faCookie } from '@fortawesome/free-solid-svg-icons';
import { faPalette, faGem, faTshirt, faGlassMartiniAlt, faShoppingCart, faBoxes,  } from '@fortawesome/free-solid-svg-icons';
import { AuthService } from '../account-forms/services/auth.service';
import { Router } from '@angular/router';
import { categories } from '../services/product.service';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { CartProduct, CartService } from '../services/cart.service';
import { NotificationService, Notification } from '../services/notification.service';


@Component({
  selector: 'app-nav',
  templateUrl: './nav.component.html',
  styleUrls: ['./nav.component.scss'],
  animations: [
    trigger('toggleMenu', [
      state('*', style({
        opacity: '1',
      })),
      state('void', style({
        opacity: '0',
        height: '0'
      })),
      transition(':enter', [
        animate('.5s')
      ]),
      transition(':leave', [
        animate('.5s')
      ]),
    ]),
  ]
})
export class NavComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  faShoppingCart = faShoppingCart;
  faBoxes = faBoxes;
  faBell = faBell;

  public openView = "";
  menuOpen = false;
  categories = categories;
  cartProducts:CartProduct[] = [];
  notifications: Notification[] = [];

  constructor(
    private library: FaIconLibrary,
    private _auth: AuthService,
    public _router: Router,
    private authService: AuthService,
    private cartService: CartService,
    private notificationService: NotificationService
  ) {
    library.addIcons( faShoppingCart, faGem, faCarrot, faCheese, faAppleAlt, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt, faDrumstickBite, faCookie);
    cartService.getCartProducts().subscribe({
      next: data => { 
        this.cartProducts = [...data];
      }
    });
    notificationService.getNotifications().subscribe({
      next: data=> {
        this.notifications = [...data];
      }
    })
  }

  toggleCategory($event: any) {
    $event.preventDefault();
    if (this.openView != "category") {
      this.openView = "category";
    }
    else {
      this.openView = "";
    }
  }

  toggleCart($event: any) {
    $event.preventDefault();
    this.menuOpen = !this.menuOpen;
  }

  ngOnInit(): void {
    this.isLoggedIn();
  }

  logout() {
    this._auth.clearStorage();
    this._router.navigate(['login']);
  }

  isLoggedIn() {
    // console.log(this._auth.getUserDetails())
    if (this._auth.getUserDetails() != null) {
      return true;
    }
    else{
      return false;
    }
  }

  currentUser() {
    return this.authService.getUserDetails()[0];
  }

  unreadNotifCount() {
    let notifCount:number = this.notifications.filter(x => x.seen == false).length;
    if (notifCount > 9) {
      return '9+';
    }
    return notifCount.toString();
  }

  cartItemCount() {
    let cartItems:number = 0;
    this.cartProducts.forEach(x => cartItems += x.amount);
    if (cartItems > 9) {
      return '9+';
    }
    return cartItems.toString();
  }

}
