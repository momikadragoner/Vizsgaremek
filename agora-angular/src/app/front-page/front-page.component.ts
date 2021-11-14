import { Component, OnInit } from '@angular/core';
import { faChevronUp, faShoppingCart } from '@fortawesome/free-solid-svg-icons';
import { faSearch } from '@fortawesome/free-solid-svg-icons';
import { faChevronDown } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-front-page',
  templateUrl: './front-page.component.html',
  styleUrls: ['./front-page.component.scss']
})
export class FrontPageComponent implements OnInit {

  faShoppingCart = faShoppingCart;
  faSearch = faSearch;
  faChevronDown = faChevronDown;

  public products = [
    {productName: "Gyöngy nyakék", sellerName: "Kiss Márta", price: "12 599", imgUrl: "assets/item2.jpg" },
    {productName: "Arany lánc", sellerName: "Nagy Erzsébet", price: "18 999", imgUrl: "assets/item1.jpg" },
    {productName: "Ásvány medál ékszer", sellerName: "Széles Lajos", price: "11 999", imgUrl: "assets/item3.jfif" },
    {productName: "Arany és kristály nyaklánc", sellerName: "Közepes Borbála", price: "19 599", imgUrl: "assets/item4.jpg" },    {productName: "Arany lánc", sellerName: "Nagy Erzsébet", price: "18 999", imgUrl: "assets/item1.jpg" },
    {productName: "Ásvány medál ékszer", sellerName: "Széles Lajos", price: "11 999", imgUrl: "assets/item3.jfif" }
  ];

  constructor() {}

  ngOnInit(): void {
  }

}
