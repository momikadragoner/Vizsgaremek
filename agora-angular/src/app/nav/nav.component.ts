import { Component, OnInit } from '@angular/core';
import { trigger, state, style, animate, transition, query, stagger } from '@angular/animations';
import { faCarrot, faAppleAlt, faBreadSlice, faCheese, faBell, IconPrefix, faDrumstickBite, faCookie } from '@fortawesome/free-solid-svg-icons';
import { faPalette, faGem, faTshirt, faGlassMartiniAlt, faShoppingCart, faBoxes,  } from '@fortawesome/free-solid-svg-icons';
import { AuthService } from '../account-forms/services/auth.service';
import { Router } from '@angular/router';
import { categories } from '../services/product.service';
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';


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

  constructor(
    private library: FaIconLibrary,
    private _auth: AuthService,
    private _router: Router,
    private authService: AuthService
  ) {
    library.addIcons( faShoppingCart, faGem, faCarrot, faCheese, faAppleAlt, faBreadSlice, faGlassMartiniAlt, faPalette, faTshirt, faDrumstickBite, faCookie);
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

  toggleNowView($event: any) {
    $event.preventDefault();
    if (this.openView != "now") {
      this.openView = "now";
    }
    else {
      this.openView = "";
    }
  }

  toggleBestView($event: any) {
    $event.preventDefault();
    if (this.openView != "best") {
      this.openView = "best";
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

}
