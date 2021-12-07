import { Component, OnInit, ViewChild } from '@angular/core';
import { faHandPaper, faBalanceScale, faTree, faEnvelope, faShoppingCart, faHeart, faTruck, faGem, faBoxes, faStar} from '@fortawesome/free-solid-svg-icons';
import { Form } from '@angular/forms';
import { productDetailed, productListShort, Product } from "../model/product";
import { User, seller } from "../model/user";
import { Review, reviews, ratingToArray } from "../model/review";

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

  public products= productListShort;
  public productDetail:Product = productDetailed;
  public seller:User = seller;
  public reviews = reviews;
  public modalVisible = false;
  public reviewContent?:any;

  openModal(id:number[]){
    this.modalVisible = true;
    this.reviewContent = reviews[id[0]]; 
  }
  ratingToArray = ratingToArray;

  @ViewChild('review') selectedReview: any;

  constructor() { }

  ngOnInit(): void {
  }

}
