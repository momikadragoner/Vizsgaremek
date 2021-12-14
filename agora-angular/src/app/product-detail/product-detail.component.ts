import { Component, OnInit, ViewChild } from '@angular/core';
import { faHandPaper, faBalanceScale, faTree, faEnvelope, faShoppingCart, faHeart, faTruck, faGem, faBoxes, faStar, IconPrefix, IconName} from '@fortawesome/free-solid-svg-icons';
import { library } from '@fortawesome/fontawesome-svg-core';
import { Form } from '@angular/forms';
import { productDetailed, productListShort, Product } from "../model/product";
import { User, seller } from "../model/user";
import { Review, reviews, ratingToArray } from "../model/review";

library.add(faHandPaper, faTree, faBalanceScale);

@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html',
  styleUrls: ['./product-detail.component.scss']
})
export class ProductDetailComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  iconName: IconName = 'tree';
  faHandPaper = faHandPaper;
  faBalanceScale = faBalanceScale;
  faTree = faTree;
  faEnvelope = faEnvelope;
  faShoppingCart = faShoppingCart;
  faHeart = faHeart;
  faTruck = faTruck;
  faGem = faGem;
  faBoxes = faBoxes;
  faStar = faStar;

  public products= productListShort;
  public productDetail:Product = productDetailed;
  public seller:User = seller;
  public reviews = reviews;
  public modalVisible = false;
  public reviewContent?:any;

  openModal(id:number[], $event: any){
    $event.preventDefault();
    this.modalVisible = true;
    this.reviewContent = reviews[id[0]]; 
  }
  ratingToArray = ratingToArray;

  @ViewChild('review') selectedReview: any;

  constructor() { }

  ngOnInit(): void {
  }

}
