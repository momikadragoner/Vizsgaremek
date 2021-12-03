import { Component, OnInit, ViewChild } from '@angular/core';
import { faHandPaper, faBalanceScale, faTree, faEnvelope, faShoppingCart, faHeart, faTruck, faGem, faBoxes, faStar} from '@fortawesome/free-solid-svg-icons';
import { Form } from '@angular/forms';
import { productDetail, productsClass, Product } from "./test-data";

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

  public products= productsClass;
  public productDetail = productDetail;

  public modalVisible = false;
  public reviewContent:any;

  openModal(id:number[]){
    this.modalVisible = true;
    this.reviewContent = productDetail.reviews[id[0]]; 
  }

  @ViewChild('review') selectedReview: any;

  constructor() { }

  ngOnInit(): void {
  }

}
