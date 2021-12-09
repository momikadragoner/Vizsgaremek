import { Component, OnInit } from '@angular/core';
import { trigger, state, style, animate, transition, query, stagger } from '@angular/animations';
import { faCarrot, faAppleAlt, faBreadSlice, faCheese } from '@fortawesome/free-solid-svg-icons';
import { faPalette, faGem, faTshirt, faGlassMartiniAlt, faShoppingCart, faBoxes } from '@fortawesome/free-solid-svg-icons';

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
  
  faCarrot = faCarrot;
  faBread = faBreadSlice;
  faApple = faAppleAlt;
  faCheese = faCheese;
  faPalette = faPalette;
  faGem = faGem;
  faTshirt = faTshirt;
  faGlassMartiniAlt = faGlassMartiniAlt;
  faShoppingCart = faShoppingCart;
  faBoxes = faBoxes;

  public openView = ""; 

  toggleCategory($event: any) {
    $event.preventDefault();
    if (this.openView != "category") {
      this.openView = "category";
    }
    else{
      this.openView = "";
    }
  }

  toggleNowView($event: any){
    $event.preventDefault();
    if (this.openView != "now") {
      this.openView = "now";
    }
    else{
      this.openView = "";
    }
  }

  toggleBestView($event: any){
    $event.preventDefault();
    if (this.openView != "best") {
      this.openView = "best";
    }
    else{
      this.openView = "";
    }
  }

  public loggedIn = false;

  constructor() { }

  ngOnInit(): void {
  }

}
