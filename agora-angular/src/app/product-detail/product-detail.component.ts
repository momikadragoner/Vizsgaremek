import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, ActivatedRoute, ParamMap, NavigationStart, NavigationEnd, NavigationError } from '@angular/router';
import { faHandPaper, faEdit, faBalanceScale, faTree, faEnvelope, faShoppingCart, faHeart, faTruck, faGem, faBoxes, faStar, IconPrefix, IconName, faChevronLeft, faChevronRight, faExclamationCircle } from '@fortawesome/free-solid-svg-icons';
// import { faStar } from '@fortawesome/free-regular-svg-icons'
import { library } from '@fortawesome/fontawesome-svg-core';
import { Form } from '@angular/forms';
//import { productDetailed, productListShort, Product } from "../model/product";
import { User as u, seller } from "../services/user.service";
import { FaIconLibrary } from '@fortawesome/angular-fontawesome';
import { HttpClient } from '@angular/common/http';
import { ProductService, Product, Review, ProductShort, ratingToArray } from '../services/product.service';
import { UserService, User } from '../services/user.service';
import { asapScheduler } from 'rxjs';



@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html',
  styleUrls: ['./product-detail.component.scss']
})
export class ProductDetailComponent implements OnInit {

  iconPrefix: IconPrefix = 'fas';
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

  product: Product = { productId: 0, name: '', sellerFirstName: '', sellerLastName: '', price: -1, inventory: -1, delivery: '', category: '', tags: [], materials: [], imgUrl: [], description: '', isPublic: true, rating: -1 };
  reviews: Review[] = [{ reviewId: 0, userId: 0, userLastName: "", userFirstName: "", title: "", review: "", rating: 0, points: 0, publishedAt: new Date() }];
  productList: ProductShort[] = [{ id: 0, name: "", seller: "", price: -1, imgUrl: "" }];
  seller: User = { id: 0, name: "", follows: -1, followers: -1, email: "", phone: "", about: "", profileImgUrl: "", headerImgUrl: "", registeredAt: new Date(), isVendor: true, isAdmin: false, companyName: undefined, siteLocation: "", website: "", takesCustomOrders: false };
  id: any;
  currentRoute: string;
  error: any;

  constructor(
    library: FaIconLibrary,
    private productService: ProductService,
    private userService: UserService,
    private route: ActivatedRoute,
    private router: Router
  ) {
    library.addIcons(faHandPaper, faTree, faBalanceScale, faExclamationCircle, faGem);
    this.currentRoute = "";
    this.router.events.subscribe((event: any) => {
      if (event instanceof NavigationStart) {
        // Show progress spinner or progress bar
        console.log('Route change detected');
      }

      if (event instanceof NavigationEnd) {
        // Hide progress spinner or progress bar
        this.currentRoute = event.url;
        this.ngOnInit();
        console.log(event);
      }

      if (event instanceof NavigationError) {
        // Hide progress spinner or progress bar

        // Present error to user
        console.log(event.error);
      }
    });
  }

  ngOnInit(): void {
    this.selectedImgIndex = 0;
    this.id = this.route.snapshot.paramMap.get('id');
    this.ShowProduct();
    //this.ShowReviews();
    this.ShowProductList();
    this.ShowUser();
    // this.route.queryParams.subscribe(params => {
    //   this.id = params['id'];
    //   console.log(params['id'])
    // });
  }

  ShowProduct() {
    this.productService.getProduct(this.id)
      .subscribe((data: Product) => this.product = { ... data}, error => this.error = error);
    console.log(this.product);
    console.log(this.error);
  }

  // ShowReviews() {
  //   this.productService.getReviews()
  //   .subscribe((data: [Review]) => this.reviews = [...data], error => this.error = error);
  // }

  ShowProductList() {
    this.productService.getProductList()
      .subscribe((data: [ProductShort]) => this.productList = [...data], error => this.error = error);
  }

  ShowUser() {
    this.userService.getUser()
      .subscribe((data: User) => this.seller = { ...data }, error => this.error = error);
  }

  //public products= productListShort;
  //public productDetail:Product = productDetailed;
  public modalVisible = false;
  public imgOpen = false;
  public newReviewOpen = false;
  public cartOpen = false;
  public reviewContent?: Review = { reviewId: 0, userId: 0, userLastName: "", userFirstName: "", title: "", review: "", rating: 0, points: 0, publishedAt: new Date() };
  public selectedImg: string = this.product.imgUrl[0];
  public selectedImgIndex: number = 0;

  openModal(id: number[], $event: any) {
    $event.preventDefault();
    this.modalVisible = true;
    this.reviewContent = this.reviews?.[id[0]];
  }

  selectImg(id: number, $event: any) {
    $event.preventDefault();
    this.selectedImg = this.product.imgUrl[id];
    this.selectedImgIndex = id;
  }

  fullScreenImg($event: any) {
    $event.preventDefault();
    this.imgOpen = true;
  }

  nextImg(next: number, $event: any) {
    $event.preventDefault();
    if (this.selectedImgIndex + next == this.product.imgUrl.length) {
      this.selectedImg = this.product.imgUrl[0];
      this.selectedImgIndex = 0;
    }
    else if (this.selectedImgIndex + next < 0) {
      this.selectedImg = this.product.imgUrl[this.product.imgUrl.length - 1];
      this.selectedImgIndex = this.product.imgUrl.length - 1;
    }
    else {
      this.selectedImg = this.product.imgUrl[this.selectedImgIndex + next];
      this.selectedImgIndex = this.selectedImgIndex + next;
    }
  }

  writeReview($event: any) {
    $event.preventDefault();
    this.newReviewOpen = true;
  }

  addToCart($event: any) {
    $event.preventDefault();
    this.cartOpen = true;
  }

  closeNewReview() {
    this.newReviewOpen = false;
  }

  ratingToArray = ratingToArray;

}
