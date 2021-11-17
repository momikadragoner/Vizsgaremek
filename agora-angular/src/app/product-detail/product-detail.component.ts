import { Component, OnInit } from '@angular/core';
import { faHandPaper, faBalanceScale, faTree, faEnvelope, faShoppingCart, faHeart, faTruck, faGem, faBoxes, faStar} from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html',
  styleUrls: ['./product-detail.component.scss']
})
export class ProductDetailComponent implements OnInit {

  faHand = faHandPaper;
  faBalanceScale = faBalanceScale;
  faTree = faTree;
  faEnvelope = faEnvelope;
  faShoppingCart = faShoppingCart;
  faHeart = faHeart;
  faTruck = faTruck;
  faGem = faGem;
  faBoxes = faBoxes;
  faStar = faStar;

  public products = [
    {productName: "Gyöngy nyakék", sellerName: "Kiss Márta", price: "12 599", imgUrl: "assets/item2.jpg" },
    {productName: "Arany lánc", sellerName: "Nagy Erzsébet", price: "18 999", imgUrl: "assets/item1.jpg" },
    {productName: "Ásvány medál ékszer", sellerName: "Széles Lajos", price: "11 999", imgUrl: "assets/item3.jfif" },
    {productName: "Arany és kristály nyaklánc", sellerName: "Közepes Borbála", price: "19 599", imgUrl: "assets/item4.jpg" }
  ];

  constructor() { }

  ngOnInit(): void {
  }

}
