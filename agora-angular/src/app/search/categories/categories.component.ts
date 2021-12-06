import { animate, state, style, transition, trigger } from '@angular/animations';
import { Component, OnInit } from '@angular/core';
import { faCarrot, faAppleAlt, faBreadSlice, faCheese, faPalette, faGem, faTshirt, faGlassMartiniAlt, faShoppingCart, faPlus, faMinus } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'product-categories',
  templateUrl: './categories.component.html',
  styleUrls: ['./categories.component.scss'],
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
export class CategoriesComponent implements OnInit {

  faCarrot = faCarrot;
  faBread = faBreadSlice;
  faApple = faAppleAlt;
  faCheese = faCheese;
  faPalette = faPalette;
  faGem = faGem;
  faTshirt = faTshirt;
  faGlassMartiniAlt = faGlassMartiniAlt;
  faShoppingCart = faShoppingCart;
  faPlus = faPlus;
  faMinus = faMinus;

  constructor() { }

  categoryOpen:boolean = false;

  toggleCategory(){
    this.categoryOpen = !this.categoryOpen;
  }

  ngOnInit(): void {
  }

}
