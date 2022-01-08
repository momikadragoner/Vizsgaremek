import { Component, OnInit, ViewChild } from '@angular/core';
import { faHandPaper, faEdit, faBalanceScale, faTree, faEnvelope, faShoppingCart, faHeart, faTruck, faGem, faBoxes, faStar, IconPrefix, IconName, faChevronLeft, faChevronRight} from '@fortawesome/free-solid-svg-icons';
// import { faStar } from '@fortawesome/free-regular-svg-icons'
import { library } from '@fortawesome/fontawesome-svg-core';
import { Form } from '@angular/forms';
import { productDetailed, productListShort, Product } from "../model/product";
import { User, seller } from "../model/user";
import { Review, reviews, ratingToArray } from "../model/review";
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { HttpClient } from '@angular/common/http';
import { ProductService, Product as Iprod } from './product-detail.service';



@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html',
  styleUrls: ['./product-detail.component.scss']
})
export class ProductDetailComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
  // iconName: IconName = 'tree';
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
  faChevronRight = faChevronRight; 
  faChevronLeft = faChevronLeft;
  faEdit = faEdit;

  public products= productListShort;
  public productDetail:Product = productDetailed;
  public seller:User = seller;
  public reviews = reviews;
  public modalVisible = false;
  public imgOpen = false;
  public newReviewOpen = false;
  public reviewContent:Review = new Review(0,"","","",0,0,new Date());
  public selectedImg:string = productDetailed.imgUrl[0];
  public selectedImgIndex:number = 0;

  openModal(id:number[], $event:any){
    $event.preventDefault();
    this.modalVisible = true;
    this.reviewContent = reviews[id[0]]; 
  }

  selectImg(id:number, $event:any){
    $event.preventDefault();
    this.selectedImg = productDetailed.imgUrl[id];
    this.selectedImgIndex = id;
  }

  fullScreenImg($event:any){
    $event.preventDefault();
    this.imgOpen = true;
  }

  nextImg(next:number, $event:any){
    $event.preventDefault();
    if (this.selectedImgIndex + next == productDetailed.imgUrl.length) {
      this.selectedImg = productDetailed.imgUrl[0];
      this.selectedImgIndex = 0;
    }
    else if (this.selectedImgIndex + next < 0) {
      this.selectedImg = productDetailed.imgUrl[productDetailed.imgUrl.length -1];
      this.selectedImgIndex = productDetailed.imgUrl.length -1;
    }
    else{
      this.selectedImg = productDetailed.imgUrl[this.selectedImgIndex + next];
      this.selectedImgIndex = this.selectedImgIndex + next;
    }
  }

  writeReview($event:any){
    $event.preventDefault();
    this.newReviewOpen = true;
  }

  closeNewReview(){
    this.newReviewOpen = false;
  }

  ratingToArray = ratingToArray;

  constructor(library: FaIconLibrary, private productService: ProductService) {
    library.addIcons(faHandPaper, faTree, faBalanceScale);
  }

  ngOnInit(): void {
  }

  product: Product | undefined;

  showProduct() {
    this.productService.getProduct()
      .subscribe((data: Product) => this.product = { ...data });
  }

}
